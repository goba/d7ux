<?php
// $Id: system.api.php,v 1.78 2009/09/25 23:48:24 dries Exp $

/**
 * @file
 * Hooks provided by Drupal core and the System module.
 */

/**
 * @addtogroup hooks
 * @{
 */

/**
 * Inform the base system and the Field API about one or more entity types.
 *
 * Inform the system about one or more entity types (i.e., object types that
 * can be loaded via entity_load() and, optionally, to which fields can be
 * attached).
 *
 * @see entity_load()
 * @see hook_entity_info_alter()
 *
 * @return
 *   An array whose keys are entity type names and whose values identify
 *   properties of those types that the  system needs to know about:
 *
 *   name: The human-readable name of the type.
 *   controller class: The name of the class that is used to load the objects.
 *     The class has to implement the DrupalEntityController interface. Leave
 *     blank to use the DefaultDrupalEntityController implementation.
 *   base table: (used by DefaultDrupalEntityController) The name of the entity
 *     type's base table.
 *   static cache: (used by DefaultDrupalEntityController) FALSE to disable
 *     static caching of entities during a page request. Defaults to TRUE.
 *   load hook: The name of the hook which should be invoked by
 *   DrupalDefaultEntityController:attachLoad(), for example 'node_load'.
 *   fieldable: Set to TRUE if you want your entity type to be fieldable.
 *   - object keys: An array describing how the Field API can extract the
 *     information it needs from the objects of the type.
 *     - id: The name of the property that contains the primary id of the
 *       object. Every object passed to the Field API must have this property
 *       and its value must be numeric.
 *     - revision: The name of the property that contains the revision id of
 *       the object. The Field API assumes that all revision ids are unique
 *       across all objects of a type.
 *       This element can be omitted if the objects of this type are not
 *       versionable.
 *     - bundle: The name of the property that contains the bundle name for the
 *       object. The bundle name defines which set of fields are attached to
 *       the object (e.g. what nodes call "content type").
 *       This element can be omitted if this type has no bundles (all objects
 *       have the same fields).
 *   - bundle keys: An array describing how the Field API can extract the
 *     information it needs from the bundle objects for this type (e.g
 *     $vocabulary objects for terms; not applicable for nodes).
 *     This element can be omitted if this type's bundles do not exist as
 *     standalone objects.
 *     - bundle: The name of the property that contains the name of the bundle
 *       object.
 *   - cacheable: A boolean indicating whether Field API should cache
 *     loaded fields for each object, reducing the cost of
 *     field_attach_load().
 *   - bundles: An array describing all bundles for this object type.
 *     Keys are bundles machine names, as found in the objects' 'bundle'
 *     property (defined in the 'object keys' entry above).
 *     - label: The human-readable name of the bundle.
 *     - admin: An array of information that allow Field UI pages (currently
 *       implemented in a contributed module) to attach themselves to the
 *       existing administration pages for the bundle.
 *       - path: the path of the bundle's main administration page, as defined
 *         in hook_menu(). If the path includes a placeholder for the bundle,
 *         the 'bundle argument', 'bundle helper' and 'real path' keys below
 *         are required.
 *       - bundle argument: The position of the placeholder in 'path', if any.
 *       - real path: The actual path (no placeholder) of the bundle's main
 *         administration page. This will be used to generate links.
 *       - access callback: As in hook_menu(). 'user_access' will be assumed if
 *         no value is provided.
 *       - access arguments: As in hook_menu().
 */
function hook_entity_info() {
  $return = array(
    'node' => array(
      'name' => t('Node'),
      'controller class' => 'NodeController',
      'base table' => 'node',
      'id key' => 'nid',
      'revision key' => 'vid',
      'fieldable' => TRUE,
      'bundle key' => 'type',
      // Node.module handles its own caching.
      // 'cacheable' => FALSE,
      // Bundles must provide human readable name so
      // we can create help and error messages about them.
      'bundles' => node_type_get_names(),
    ),
  );
  return $return;
}

/**
 * Alter the entity info.
 *
 * Modules may implement this hook to alter the information that defines an
 * entity. All properties that are available in hook_entity_info() can be
 * altered here.
 *
 * @see hook_entity_info()
 *
 * @param $entity_info
 *   The entity info array, keyed by entity name.
 */
function hook_entity_info_alter(&$entity_info) {
  // Set the controller class for nodes to an alternate implementation of the
  // DrupalEntityController interface.
  $entity_info['node']['controller class'] = 'MyCustomNodeController';
}

/**
 * Perform periodic actions.
 *
 * This hook will only be called if cron.php is run (e.g. by crontab).
 *
 * Modules that require to schedule some commands to be executed at regular
 * intervals can implement hook_cron(). The engine will then call the hook
 * at the appropriate intervals defined by the administrator. This interface
 * is particularly handy to implement timers or to automate certain tasks.
 * Database maintenance, recalculation of settings or parameters are good
 * candidates for cron tasks.
 *
 * Short-running or not resource intensive tasks can be executed directly.
 *
 * Long-running tasks should use the queue API. To do this, one or more queues
 * need to be defined via hook_cron_queue_info(). Items that need to be
 * processed are appended to the defined queue, instead of processing them
 * directly in hook_cron().
 * Examples of jobs that are good candidates for
 * hook_cron_queue_info() include automated mailing, retrieving remote data, and
 * intensive file tasks.
 *
 * @return
 *   None.
 *
 * @see hook_cron_queue_info()
 */
function hook_cron() {
  // Short-running operation example, not using a queue:
  // Delete all expired records since the last cron run.
  $expires = variable_get('mymodule_cron_last_run', REQUEST_TIME);
  db_delete('mymodule_table')
    ->condition('expires', $expires, '>=')
    ->execute();
  variable_set('mymodule_cron_last_run', REQUEST_TIME);

  // Long-running operation example, leveraging a queue:
  // Fetch feeds from other sites.
  $result = db_query('SELECT * FROM {aggregator_feed} WHERE checked + refresh < :time AND refresh != :never', array(
    ':time' => REQUEST_TIME,
    ':never' => AGGREGATOR_CLEAR_NEVER,
  ));
  $queue = DrupalQueue::get('aggregator_feeds');
  foreach ($result as $feed) {
    $queue->createItem($feed);
  }
}

/**
 * Declare queues holding items that need to be run periodically.
 *
 * While there can be only one hook_cron() process running at the same time,
 * there can be any number of processes defined here running. Because of
 * this, long running tasks are much better suited for this API. Items queued
 * in hook_cron() might be processed in the same cron run if there are not many
 * items in the queue, otherwise it might take several requests, which can be
 * run in parallel.
 *
 * @return
 *   An associative array where the key is the queue name and the value is
 *   again an associative array. Possible keys are:
 *   - 'worker callback': The name of the function to call. It will be called
 *     with one argument, the item created via DrupalQueue::createItem() in
 *     hook_cron().
 *   - 'time': (optional) How much time Drupal should spend on calling this
 *     worker in seconds. Defaults to 15.
 *
 * @see hook_cron()
 */
function hook_cron_queue_info() {
  $queues['aggregator_feeds'] = array(
    'worker callback' => 'aggregator_refresh',
    'time' => 15,
  );
  return $queues;
}

/**
 * Allows modules to declare their own Forms API element types and specify their
 * default values.
 *
 * This hook allows modules to declare their own form element types and to
 * specify their default values. The values returned by this hook will be
 * merged with the elements returned by hook_form() implementations and so
 * can return defaults for any Form APIs keys in addition to those explicitly
 * mentioned below.
 *
 * Each of the form element types defined by this hook is assumed to have
 * a matching theme function, e.g. theme_elementtype(), which should be
 * registered with hook_theme() as normal.
 *
 * Form more information about custom element types see the explanation at
 * http://drupal.org/node/169815.
 *
 * @return
 *  An associative array describing the element types being defined. The array
 *  contains a sub-array for each element type, with the machine-readable type
 *  name as the key. Each sub-array has a number of possible attributes:
 *  - "#input": boolean indicating whether or not this element carries a value
 *    (even if it's hidden).
 *  - "#process": array of callback functions taking $element and $form_state.
 *  - "#after_build": array of callback functions taking $element and $form_state.
 *  - "#validate": array of callback functions taking $form and $form_state.
 *  - "#element_validate": array of callback functions taking $element and
 *    $form_state.
 *  - "#pre_render": array of callback functions taking $element and $form_state.
 *  - "#post_render": array of callback functions taking $element and $form_state.
 *  - "#submit": array of callback functions taking $form and $form_state.
 *
 * @see hook_element_info_alter()
 * @see system_element_info()
 */
function hook_element_info() {
  $types['filter_format'] = array(
    '#input' => TRUE,
  );
  return $types;
}

/**
 * Alter the element type information returned from modules.
 *
 * A module may implement this hook in order to alter the element type defaults
 * defined by a module.
 *
 * @param &$type
 *   All element type defaults as collected by hook_element_info().
 *
 * @see hook_element_info()
 */
function hook_element_info_alter(&$type) {
  // Decrease the default size of textfields.
  if (isset($type['textfield']['#size'])) {
    $type['textfield']['#size'] = 40;
  }
}

/**
 * Perform cleanup tasks.
 *
 * This hook is run at the end of each page request. It is often used for
 * page logging and printing out debugging information.
 *
 * Only use this hook if your code must run even for cached page views.
 * If you have code which must run once on all non cached pages, use
 * hook_init instead. Thats the usual case. If you implement this hook
 * and see an error like 'Call to undefined function', it is likely that
 * you are depending on the presence of a module which has not been loaded yet.
 * It is not loaded because Drupal is still in bootstrap mode.
 *
 * @param $destination
 *   If this hook is invoked as part of a drupal_goto() call, then this argument
 *   will be a fully-qualified URL that is the destination of the redirect.
 *   Modules may use this to react appropriately; for example, nothing should
 *   be output in this case, because PHP will then throw a "headers cannot be
 *   modified" error when attempting the redirection.
 */
function hook_exit($destination = NULL) {
  db_update('counter')
    ->expression('hits', 'hits + 1')
    ->condition('type', 1)
    ->execute();
}

/**
 * Perform necessary alterations to the JavaScript before it is presented on
 * the page.
 *
 * @param $javascript
 *   An array of all JavaScript being presented on the page.
 * @see drupal_add_js()
 * @see drupal_get_js()
 * @see drupal_js_defaults()
 */
function hook_js_alter(&$javascript) {
  // Swap out jQuery to use an updated version of the library.
  $javascript['misc/jquery.js']['data'] = drupal_get_path('module', 'jquery_update') . '/jquery.js';
}

/**
 * Registers JavaScript/CSS libraries associated with a module.
 *
 * Modules implementing this return an array of arrays. The key to each
 * sub-array is the machine readable name of the library. Each library may
 * contain the following items:
 *
 * - 'title': The human readable name of the library.
 * - 'website': The URL of the library's web site.
 * - 'version': A string specifying the version of the library; intentionally
 *   not a float because a version like "1.2.3" is not a valid float. Use PHP's
 *   version_compare() to compare different versions.
 * - 'js': An array of JavaScript elements; each element's key is used as $data
 *   argument, each element's value is used as $options array for
 *   drupal_add_js(). To add library-specific (not module-specific) JavaScript
 *   settings, the key may be skipped, the value must specify
 *   'type' => 'setting', and the actual settings must be contained in a 'data'
 *   element of the value.
 * - 'css': Like 'js', an array of CSS elements passed to drupal_add_css().
 * - 'dependencies': An array of libraries that are required for a library. Each
 *   element is an array containing the module and name of the registered
 *   library. Note that all dependencies for each dependent library will be
 *   added when this library is added.
 *
 * Registered information for a library should contain re-usable data only.
 * Module- or implementation-specific data and integration logic should be added
 * separately.
 *
 * @return
 *   An array defining libraries associated with a module.
 *
 * @see system_library()
 * @see drupal_add_library()
 * @see drupal_get_library()
 */
function hook_library() {
  // Library One.
  $libraries['library-1'] = array(
    'title' => 'Library One',
    'website' => 'http://example.com/library-1',
    'version' => '1.2',
    'js' => array(
      drupal_get_path('module', 'my_module') . '/library-1.js' => array(),
    ),
    'css' => array(
      drupal_get_path('module', 'my_module') . '/library-2.css' => array(
        'type' => 'file',
        'media' => 'screen',
      ),
    ),
  );
  // Library Two.
  $libraries['library-2'] = array(
    'title' => 'Library Two',
    'website' => 'http://example.com/library-2',
    'version' => '3.1-beta1',
    'js' => array(
      // JavaScript settings may use the 'data' key.
      array(
        'type' => 'setting',
        'data' => array('library2' => TRUE),
      ),
    ),
    'dependencies' => array(
      // Require jQuery UI core by System module.
      array('system' => 'ui'),
      // Require our other library.
      array('my_module', 'library-1'),
      // Require another library.
      array('other_module', 'library-3'),
    ),
  );
  return $libraries;
}

/**
 * Alters the JavaScript/CSS library registry.
 *
 * Allows certain, contributed modules to update libraries to newer versions
 * while ensuring backwards compatibility. In general, such manipulations should
 * only be done by designated modules, since most modules that integrate with a
 * certain library also depend on the API of a certain library version.
 *
 * @param $libraries
 *   The JavaScript/CSS libraries provided by $module. Keyed by internal library
 *   name and passed by reference.
 * @param $module
 *   The name of the module that registered the libraries.
 *
 * @see hook_library()
 */
function hook_library_alter(&$libraries, $module) {
  // Update Farbtastic to version 2.0.
  if ($module == 'system' && isset($libraries['farbtastic'])) {
    // Verify existing version is older than the one we are updating to.
    if (version_compare($libraries['farbtastic']['version'], '2.0', '<')) {
      // Update the existing Farbtastic to version 2.0.
      $libraries['farbtastic']['version'] = '2.0';
      $libraries['farbtastic']['js'] = array(
        drupal_get_path('module', 'farbtastic_update') . '/farbtastic-2.0.js' => array(),
      );
    }
  }
}

/**
 * Alter CSS files before they are output on the page.
 *
 * @param $css
 *   An array of all CSS items (files and inline CSS) being requested on the page.
 * @see drupal_add_css()
 * @see drupal_get_css()
 */
function hook_css_alter(&$css) {
  // Remove defaults.css file.
  unset($css[drupal_get_path('module', 'system') . '/defaults.css']);
}

/**
 * Add elements to a page before it is rendered.
 *
 * Use this hook when you want to add elements at the page level. For your
 * additions to be printed, they have to be placed below a top level array key
 * of the $page array that has the name of a region of the active theme.
 *
 * By default, valid region keys are 'page_top', 'header', 'sidebar_first',
 * 'content', 'sidebar_second' and 'page_bottom'. To get a list of all regions
 * of the active theme, use system_region_list($theme). Note that $theme is a
 * global variable.
 *
 * If you want to alter the elements added by other modules or if your module
 * depends on the elements of other modules, use hook_page_alter() instead which
 * runs after this hook.
 *
 * @param $page
 *   Nested array of renderable elements that make up the page.
 *
 * @see hook_page_alter()
 * @see drupal_render_page()
 */
function hook_page_build(&$page) {
  if (menu_get_object('node', 1)) {
    // We are on a node detail page. Append a standard disclaimer to the
    // content region.
    $page['content']['disclaimer'] = array(
      '#markup' => t('Acme, Inc. is not responsible for the contents of this sample code.'),
      '#weight' => 25,
    );
  }
}

/**
 * Perform alterations before a page is rendered.
 *
 * Use this hook when you want to remove or alter elements at the page
 * level, or add elements at the page level that depend on an other module's
 * elements (this hook runs after hook_page_build().
 *
 * If you are making changes to entities such as forms, menus, or user
 * profiles, use those objects' native alter hooks instead (hook_form_alter(),
 * for example).
 *
 * The $page array contains top level elements for each block region:
 * @code
 *   $page['page_top']
 *   $page['header']
 *   $page['sidebar_first']
 *   $page['content']
 *   $page['sidebar_second']
 *   $page['page_bottom']
 * @endcode
 *
 * The 'content' element contains the main content of the current page, and its
 * structure will vary depending on what module is responsible for building the
 * page. Some legacy modules may not return structured content at all: their
 * pre-rendered markup will be located in $page['content']['main']['#markup'].
 *
 * Pages built by Drupal's core Node and Blog modules use a standard structure:
 *
 * @code
 *   // Node body.
 *   $page['content']['nodes'][$nid]['body']
 *   // Array of links attached to the node (add comments, read more).
 *   $page['content']['nodes'][$nid]['links']
 *   // The node object itself.
 *   $page['content']['nodes'][$nid]['#node']
 *   // The results pager.
 *   $page['content']['pager']
 * @endcode
 *
 * Blocks may be referenced by their module/delta pair within a region:
 * @code
 *   // The login block in the first sidebar region.
 *   $page['sidebar_first']['user_login']['#block'];
 * @endcode
 *
 * @param $page
 *   Nested array of renderable elements that make up the page.
 *
 * @see hook_page_build()
 * @see drupal_render_page()
 */
function hook_page_alter(&$page) {
  // Add help text to the user login block.
  $page['sidebar_first']['user_login']['help'] = array(
    '#weight' => -10,
    '#markup' => t('To post comments or add new content, you first have to log in.'),
  );
}

/**
 * Perform alterations before a form is rendered.
 *
 * One popular use of this hook is to add form elements to the node form. When
 * altering a node form, the node object retrieved at from $form['#node'].
 *
 * Note that instead of hook_form_alter(), which is called for all forms, you
 * can also use hook_form_FORM_ID_alter() to alter a specific form.
 *
 * @param $form
 *   Nested array of form elements that comprise the form.
 * @param $form_state
 *   A keyed array containing the current state of the form.
 * @param $form_id
 *   String representing the name of the form itself. Typically this is the
 *   name of the function that generated the form.
 */
function hook_form_alter(&$form, &$form_state, $form_id) {
  if (isset($form['type']) && $form['type']['#value'] . '_node_settings' == $form_id) {
    $form['workflow']['upload_' . $form['type']['#value']] = array(
      '#type' => 'radios',
      '#title' => t('Attachments'),
      '#default_value' => variable_get('upload_' . $form['type']['#value'], 1),
      '#options' => array(t('Disabled'), t('Enabled')),
    );
  }
}

/**
 * Provide a form-specific alteration instead of the global hook_form_alter().
 *
 * Modules can implement hook_form_FORM_ID_alter() to modify a specific form,
 * rather than implementing hook_form_alter() and checking the form ID, or
 * using long switch statements to alter multiple forms.
 *
 * Note that this hook fires before hook_form_alter(). Therefore all
 * implementations of hook_form_FORM_ID_alter() will run before all implementations
 * of hook_form_alter(), regardless of the module order.
 *
 * @param $form
 *   Nested array of form elements that comprise the form.
 * @param $form_state
 *   A keyed array containing the current state of the form.
 *
 * @see drupal_prepare_form().
 */
function hook_form_FORM_ID_alter(&$form, &$form_state) {
  // Modification for the form with the given form ID goes here. For example, if
  // FORM_ID is "user_register" this code would run only on the user
  // registration form.

  // Add a checkbox to registration form about agreeing to terms of use.
  $form['terms_of_use'] = array(
    '#type' => 'checkbox',
    '#title' => t("I agree with the website's terms and conditions."),
    '#required' => TRUE,
  );
}

/**
 * Map form_ids to builder functions.
 *
 * This hook allows modules to build multiple forms from a single form "factory"
 * function but each form will have a different form id for submission,
 * validation, theming or alteration by other modules.
 *
 * The callback arguments will be passed as parameters to the function. Callers
 * of drupal_get_form() are also able to pass in parameters. These will be
 * appended after those specified by hook_forms().
 *
 * See node_forms() for an actual example of how multiple forms share a common
 * building function.
 *
 * @param $form_id
 *   The unique string identifying the desired form.
 * @param $args
 *   An array containing the original arguments provided to drupal_get_form().
 * @return
 *   An array keyed by form_id with callbacks and optional, callback arguments.
 */
function hook_forms($form_id, $args) {
  $forms['mymodule_first_form'] = array(
    'callback' => 'mymodule_form_builder',
    'callback arguments' => array('some parameter'),
  );
  $forms['mymodule_second_form'] = array(
    'callback' => 'mymodule_form_builder',
  );

  return $forms;
}

/**
 * Perform setup tasks. See also, hook_init.
 *
 * This hook is run at the beginning of the page request. It is typically
 * used to set up global parameters which are needed later in the request.
 *
 * Only use this hook if your code must run even for cached page views.This hook
 * is called before modules or most include files are loaded into memory.
 * It happens while Drupal is still in bootstrap mode.
 */
function hook_boot() {
  // we need user_access() in the shutdown function. make sure it gets loaded
  drupal_load('module', 'user');
  register_shutdown_function('devel_shutdown');
}

/**
 * Perform setup tasks. See also, hook_boot.
 *
 * This hook is run at the beginning of the page request. It is typically
 * used to set up global parameters which are needed later in the request.
 * when this hook is called, all modules are already loaded in memory.
 *
 * For example, this hook is a typical place for modules to add CSS or JS
 * that should be present on every page. This hook is not run on cached
 * pages - though CSS or JS added this way will be present on a cached page.
 */
function hook_init() {
  drupal_add_css(drupal_get_path('module', 'book') . '/book.css');
}

/**
 * Define image toolkits provided by this module.
 *
 * The file which includes each toolkit's functions must be declared as part of
 * the files array in the module .info file so that the registry will find and
 * parse it.
 *
 * The toolkit's functions must be named image_toolkitname_operation().
 * where the operation may be:
 *   - 'load': Required. See image_gd_load() for usage.
 *   - 'save': Required. See image_gd_save() for usage.
 *   - 'settings': Optional. See image_gd_settings() for usage.
 *   - 'resize': Optional. See image_gd_resize() for usage.
 *   - 'rotate': Optional. See image_gd_rotate() for usage.
 *   - 'crop': Optional. See image_gd_crop() for usage.
 *   - 'desaturate': Optional. See image_gd_desaturate() for usage.
 *
 * @return
 *   An array with the toolkit name as keys and sub-arrays with these keys:
 *     - 'title': A string with the toolkit's title.
 *     - 'available': A Boolean value to indicate that the toolkit is operating
 *       properly, e.g. all required libraries exist.
 *
 * @see system_image_toolkits()
 */
function hook_image_toolkits() {
  return array(
    'working' => array(
      'title' => t('A toolkit that works.'),
      'available' => TRUE,
    ),
    'broken' => array(
      'title' => t('A toolkit that is "broken" and will not be listed.'),
      'available' => FALSE,
    ),
  );
}

/**
 * Alter an email message created with the drupal_mail() function.
 *
 * hook_mail_alter() allows modification of email messages created and sent
 * with drupal_mail(). Usage examples include adding and/or changing message
 * text, message fields, and message headers.
 *
 * Email messages sent using functions other than drupal_mail() will not
 * invoke hook_mail_alter(). For example, a contributed module directly
 * calling the drupal_mail_sending_system()->mail() or PHP mail() function
 * will not invoke this hook. All core modules use drupal_mail() for
 * messaging, it is best practice but not manditory in contributed modules.
 *
 * @param $message
 *   An array containing the message data. Keys in this array include:
 *  - 'id':
 *     The drupal_mail() id of the message. Look at module source code or
 *     drupal_mail() for possible id values. 
 *  - 'to':
 *     The address or addresses the message will be sent to. The
 *     formatting of this string must comply with RFC 2822.
 *  - 'from':
 *     The address the message will be marked as being from, which is
 *     either a custom address or the site-wide default email address.
 *  - 'subject':
 *     Subject of the email to be sent. This must not contain any newline
 *     characters, or the email may not be sent properly.
 *  - 'body':
 *     An array of strings containing the message text. The message body is
 *     created by concatenating the individual array strings into a single text 
 *     string using "\n\n" as a separator.
 *  - 'headers':
 *     Associative array containing mail headers, such as From, Sender,
 *     MIME-Version, Content-Type, etc.
 *  - 'params':
 *     An array of optional parameters supplied by the caller of drupal_mail()
 *     that is used to build the message before hook_mail_alter() is invoked.
 *  - 'language':
 *     The language object used to build the message before hook_mail_alter()
 *     is invoked.
 *
 * @see drupal_mail()
 */
function hook_mail_alter(&$message) {
  if ($message['id'] == 'modulename_messagekey') {
    $message['body'][] = "--\nMail sent out from " . variable_get('sitename', t('Drupal'));
  }
}

/**
 * Alter the information parsed from module and theme .info files
 *
 * This hook is invoked in _system_get_module_data() and in _system_get_theme_data().
 * A module may implement this hook in order to add to or alter the data
 * generated by reading the .info file with drupal_parse_info_file().
 *
 * @param &$info
 *   The .info file contents, passed by reference so that it can be altered.
 * @param $file
 *   Full information about the module or theme, including $file->name, and
 *   $file->filename
 * @param $type
 *   Either 'module' or 'theme', depending on the type of .info file that was
 *   passed.
 */
function hook_system_info_alter(&$info, $file, $type) {
  // Only fill this in if the .info file does not define a 'datestamp'.
  if (empty($info['datestamp'])) {
    $info['datestamp'] = filemtime($file->filename);
  }
}

/**
 * Define user permissions.
 *
 * This hook can supply permissions that the module defines, so that they
 * can be selected on the user permissions page and used to grant or restrict
 * access to actions the module performs.
 *
 * Permissions are checked using user_access().
 *
 * For a detailed usage example, see page_example.module.
 *
 * @return
 *   An array of which permission names are the keys and their corresponding
 *   values are descriptions of each permission.
 *   The permission names (keys of the array) must not be wrapped with
 *   the t() function, since the string extractor takes care of
 *   extracting permission names defined in the perm hook for
 *   translation. The permission descriptions (values of the array)
 *   should be wrapped in the t() function so they can be translated.
 */
function hook_permission() {
  return array(
    'administer my module' =>  array(
      'title' => t('Administer my module'),
      'description' => t('Perform administration tasks for my module.'),
    ),
  );
}

/**
 * Register a module (or theme's) theme implementations.
 *
 * Modules and themes implementing this return an array of arrays. The key
 * to each sub-array is the internal name of the hook, and the array contains
 * info about the hook. Each array may contain the following items:
 *
 * - arguments: (required) An array of arguments that this theme hook uses. This
 *   value allows the theme layer to properly utilize templates. The
 *   array keys represent the name of the variable, and the value will be
 *   used as the default value if not specified to the theme() function.
 *   These arguments must be in the same order that they will be given to
 *   the theme() function.
 * - file: The file the implementation resides in. This file will be included
 *   prior to the theme being rendered, to make sure that the function or
 *   preprocess function (as needed) is actually loaded; this makes it possible
 *   to split theme functions out into separate files quite easily.
 * - path: Override the path of the file to be used. Ordinarily the module or
 *   theme path will be used, but if the file will not be in the default path,
 *   include it here. This path should be relative to the Drupal root
 *   directory.
 * - template: If specified, this theme implementation is a template, and this
 *   is the template file <b>without an extension</b>. Do not put .tpl.php
 *   on this file; that extension will be added automatically by the default
 *   rendering engine (which is PHPTemplate). If 'path', above, is specified,
 *   the template should also be in this path.
 * - function: If specified, this will be the function name to invoke for this
 *   implementation. If neither file nor function is specified, a default
 *   function name will be assumed. For example, if a module registers
 *   the 'node' theme hook, 'theme_node' will be assigned to its function.
 *   If the chameleon theme registers the node hook, it will be assigned
 *   'chameleon_node' as its function.
 * - pattern: A regular expression pattern to be used to allow this theme
 *   implementation to have a dynamic name. The convention is to use __ to
 *   differentiate the dynamic portion of the theme. For example, to allow
 *   forums to be themed individually, the pattern might be: 'forum__'. Then,
 *   when the forum is themed, call: <code>theme(array('forum__' . $tid, 'forum'),
 *   $forum)</code>.
 * - preprocess functions: A list of functions used to preprocess this data.
 *   Ordinarily this won't be used; it's automatically filled in. By default,
 *   for a module this will be filled in as template_preprocess_HOOK. For
 *   a theme this will be filled in as phptemplate_preprocess and
 *   phptemplate_preprocess_HOOK as well as themename_preprocess and
 *   themename_preprocess_HOOK.
 * - override preprocess functions: Set to TRUE when a theme does NOT want the
 *   standard preprocess functions to run. This can be used to give a theme
 *   FULL control over how variables are set. For example, if a theme wants
 *   total control over how certain variables in the page.tpl.php are set,
 *   this can be set to true. Please keep in mind that when this is used
 *   by a theme, that theme becomes responsible for making sure necessary
 *   variables are set.
 * - type: (automatically derived) Where the theme hook is defined:
 *   'module', 'theme_engine', or 'theme'.
 * - theme path: (automatically derived) The directory path of the theme or
 *   module, so that it doesn't need to be looked up.
 * - theme paths: (automatically derived) An array of template suggestions where
 *   .tpl.php files related to this theme hook may be found.
 *
 * The following parameters are all optional.
 *
 * @param $existing
 *   An array of existing implementations that may be used for override
 *   purposes. This is primarily useful for themes that may wish to examine
 *   existing implementations to extract data (such as arguments) so that
 *   it may properly register its own, higher priority implementations.
 * @param $type
 *   What 'type' is being processed. This is primarily useful so that themes
 *   tell if they are the actual theme being called or a parent theme.
 *   May be one of:
 *     - module: A module is being checked for theme implementations.
 *     - base_theme_engine: A theme engine is being checked for a theme which is a parent of the actual theme being used.
 *     - theme_engine: A theme engine is being checked for the actual theme being used.
 *     - base_theme: A base theme is being checked for theme implementations.
 *     - theme: The actual theme in use is being checked.
 * @param $theme
 *   The actual name of theme that is being being checked (mostly only useful for
 *   theme engine).
 * @param $path
 *   The directory path of the theme or module, so that it doesn't need to be
 *   looked up.
 *
 * @return
 *   A keyed array of theme hooks.
 */
function hook_theme($existing, $type, $theme, $path) {
  return array(
    'forum_display' => array(
      'arguments' => array('forums' => NULL, 'topics' => NULL, 'parents' => NULL, 'tid' => NULL, 'sortby' => NULL, 'forum_per_page' => NULL),
    ),
    'forum_list' => array(
      'arguments' => array('forums' => NULL, 'parents' => NULL, 'tid' => NULL),
    ),
    'forum_topic_list' => array(
      'arguments' => array('tid' => NULL, 'topics' => NULL, 'sortby' => NULL, 'forum_per_page' => NULL),
    ),
    'forum_icon' => array(
      'arguments' => array('new_posts' => NULL, 'num_posts' => 0, 'comment_mode' => 0, 'sticky' => 0),
    ),
  );
}

/**
 * Alter the theme registry information returned from hook_theme().
 *
 * The theme registry stores information about all available theme hooks,
 * including which callback functions those hooks will call when triggered,
 * what template files are exposed by these hooks, and so on.
 *
 * Note that this hook is only executed as the theme cache is re-built.
 * Changes here will not be visible until the next cache clear.
 *
 * The $theme_registry array is keyed by theme hook name, and contains the
 * information returned from hook_theme(), as well as additional properties
 * added by _theme_process_registry().
 *
 * For example:
 * @code
 *  $theme_registry['user_profile'] = array(
 *    'arguments' => array(
 *      'account' => NULL,
 *    ),
 *    'template' => 'modules/user/user-profile',
 *    'file' => 'modules/user/user.pages.inc',
 *    'type' => 'module',
 *    'theme path' => 'modules/user',
 *    'theme paths' => array(
 *      0 => 'modules/user',
 *    ),
 *    'preprocess functions' => array(
 *      0 => 'template_preprocess',
 *      1 => 'template_preprocess_user_profile',
 *     ),
 *   )
 * );
 * @endcode
 *
 * @param $theme_registry
 *   The entire cache of theme registry information, post-processing.
 * @see hook_theme()
 * @see _theme_process_registry()
 */
function hook_theme_registry_alter(&$theme_registry) {
  // Kill the next/previous forum topic navigation links.
  foreach ($theme_registry['forum_topic_navigation']['preprocess functions'] as $key => $value) {
    if ($value = 'template_preprocess_forum_topic_navigation') {
      unset($theme_registry['forum_topic_navigation']['preprocess functions'][$key]);
    }
  }
}

/**
 * Register XML-RPC callbacks.
 *
 * This hook lets a module register callback functions to be called when
 * particular XML-RPC methods are invoked by a client.
 *
 * @return
 *   An array which maps XML-RPC methods to Drupal functions. Each array
 *   element is either a pair of method => function or an array with four
 *   entries:
 *   - The XML-RPC method name (for example, module.function).
 *   - The Drupal callback function (for example, module_function).
 *   - The method signature is an array of XML-RPC types. The first element
 *     of this array is the type of return value and then you should write a
 *     list of the types of the parameters. XML-RPC types are the following
 *     (See the types at http://www.xmlrpc.com/spec):
 *       - "boolean": 0 (false) or 1 (true).
 *       - "double": a floating point number (for example, -12.214).
 *       - "int": a integer number (for example,  -12).
 *       - "array": an array without keys (for example, array(1, 2, 3)).
 *       - "struct": an associative array or an object (for example,
 *          array('one' => 1, 'two' => 2)).
 *       - "date": when you return a date, then you may either return a
 *          timestamp (time(), mktime() etc.) or an ISO8601 timestamp. When
 *          date is specified as an input parameter, then you get an object,
 *          which is described in the function xmlrpc_date
 *       - "base64": a string containing binary data, automatically
 *          encoded/decoded automatically.
 *       - "string": anything else, typically a string.
 *   - A descriptive help string, enclosed in a t() function for translation
 *     purposes.
 *   Both forms are shown in the example.
 */
function hook_xmlrpc() {
  return array(
    'drupal.login' => 'drupal_login',
    array(
      'drupal.site.ping',
      'drupal_directory_ping',
      array('boolean', 'string', 'string', 'string', 'string', 'string'),
      t('Handling ping request'))
  );
}

/**
 * Log an event message
 *
 * This hook allows modules to route log events to custom destinations, such as
 * SMS, Email, pager, syslog, ...etc.
 *
 * @param $log_entry
 *   An associative array containing the following keys:
 *   - type: The type of message for this entry. For contributed modules, this is
 *     normally the module name. Do not use 'debug', use severity WATCHDOG_DEBUG instead.
 *   - user: The user object for the user who was logged in when the event happened.
 *   - request_uri: The Request URI for the page the event happened in.
 *   - referer: The page that referred the use to the page where the event occurred.
 *   - ip: The IP address where the request for the page came from.
 *   - timestamp: The UNIX timetamp of the date/time the event occurred
 *   - severity: One of the following values as defined in RFC 3164 http://www.faqs.org/rfcs/rfc3164.html
 *     WATCHDOG_EMERG     Emergency: system is unusable
 *     WATCHDOG_ALERT     Alert: action must be taken immediately
 *     WATCHDOG_CRITICAL  Critical: critical conditions
 *     WATCHDOG_ERROR     Error: error conditions
 *     WATCHDOG_WARNING   Warning: warning conditions
 *     WATCHDOG_NOTICE    Notice: normal but significant condition
 *     WATCHDOG_INFO      Informational: informational messages
 *     WATCHDOG_DEBUG     Debug: debug-level messages
 *   - link: an optional link provided by the module that called the watchdog() function.
 *   - message: The text of the message to be logged.
 */
function hook_watchdog(array $log_entry) {
  global $base_url, $language;

  $severity_list = array(
    WATCHDOG_EMERG    => t('Emergency'),
    WATCHDOG_ALERT    => t('Alert'),
    WATCHDOG_CRITICAL => t('Critical'),
    WATCHDOG_ERROR    => t('Error'),
    WATCHDOG_WARNING  => t('Warning'),
    WATCHDOG_NOTICE   => t('Notice'),
    WATCHDOG_INFO     => t('Info'),
    WATCHDOG_DEBUG    => t('Debug'),
  );

  $to = 'someone@example.com';
  $params = array();
  $params['subject'] = t('[@site_name] @severity_desc: Alert from your web site', array(
    '@site_name' => variable_get('site_name', 'Drupal'),
    '@severity_desc' => $severity_list[$log_entry['severity']],
  ));

  $params['message']  = "\nSite:         @base_url";
  $params['message'] .= "\nSeverity:     (@severity) @severity_desc";
  $params['message'] .= "\nTimestamp:    @timestamp";
  $params['message'] .= "\nType:         @type";
  $params['message'] .= "\nIP Address:   @ip";
  $params['message'] .= "\nRequest URI:  @request_uri";
  $params['message'] .= "\nReferrer URI: @referer_uri";
  $params['message'] .= "\nUser:         (@uid) @name";
  $params['message'] .= "\nLink:         @link";
  $params['message'] .= "\nMessage:      \n\n@message";

  $params['message'] = t($params['message'], array(
    '@base_url'      => $base_url,
    '@severity'      => $log_entry['severity'],
    '@severity_desc' => $severity_list[$log_entry['severity']],
    '@timestamp'     => format_date($log_entry['timestamp']),
    '@type'          => $log_entry['type'],
    '@ip'            => $log_entry['ip'],
    '@request_uri'   => $log_entry['request_uri'],
    '@referer_uri'   => $log_entry['referer'],
    '@uid'           => $log_entry['user']->uid,
    '@name'          => $log_entry['user']->name,
    '@link'          => strip_tags($log_entry['link']),
    '@message'       => strip_tags($log_entry['message']),
  ));

  drupal_mail('emaillog', 'entry', $to, $language, $params);
}

/**
 * Prepare a message based on parameters; called from drupal_mail().
 *
 * @param $key
 *   An identifier of the mail.
 * @param $message
 *  An array to be filled in. Keys in this array include:
 *  - 'id':
 *     An id to identify the mail sent. Look at module source code
 *     or drupal_mail() for possible id values.
 *  - 'to':
 *     The address or addresses the message will be sent to. The
 *     formatting of this string must comply with RFC 2822.
 *  - 'subject':
 *     Subject of the e-mail to be sent. This must not contain any newline
 *     characters, or the mail may not be sent properly. drupal_mail() sets
 *     this to an empty string when the hook is invoked.
 *  - 'body':
 *     An array of lines containing the message to be sent. Drupal will format
 *     the correct line endings for you. drupal_mail() sets this to an empty
 *     array when the hook is invoked.
 *  - 'from':
 *     The address the message will be marked as being from, which is
 *     set by drupal_mail() to either a custom address or the site-wide
 *     default email address when the hook is invoked.
 *  - 'headers':
 *     Associative array containing mail headers, such as From, Sender,
 *     MIME-Version, Content-Type, etc. drupal_mail() pre-fills
 *     several headers in this array.
 * @param $params
 *   An array of parameters supplied by the caller of drupal_mail().
 */
function hook_mail($key, &$message, $params) {
  $account = $params['account'];
  $context = $params['context'];
  $variables = array(
    '%site_name' => variable_get('site_name', 'Drupal'),
    '%username' => $account->name,
  );
  if ($context['hook'] == 'taxonomy') {
    $object = $params['object'];
    $vocabulary = taxonomy_vocabulary_load($object->vid);
    $variables += array(
      '%term_name' => $object->name,
      '%term_description' => $object->description,
      '%term_id' => $object->tid,
      '%vocabulary_name' => $vocabulary->name,
      '%vocabulary_description' => $vocabulary->description,
      '%vocabulary_id' => $vocabulary->vid,
    );
  }

  // Node-based variable translation is only available if we have a node.
  if (isset($params['node'])) {
    $node = $params['node'];
    $variables += array(
      '%uid' => $node->uid,
      '%node_url' => url('node/' . $node->nid, array('absolute' => TRUE)),
      '%node_type' => node_type_get_name($node),
      '%title' => $node->title,
      '%teaser' => $node->teaser,
      '%body' => $node->body,
    );
  }
  $subject = strtr($context['subject'], $variables);
  $body = strtr($context['message'], $variables);
  $message['subject'] .= str_replace(array("\r", "\n"), '', $subject);
  $message['body'][] = drupal_html_to_text($body);
}

/**
 * Add a list of cache tables to be cleared.
 *
 * This hook allows your module to add cache table names to the list of cache
 * tables that will be cleared by the Clear button on the Performance page or
 * whenever drupal_flush_all_caches is invoked.
 *
 * @see drupal_flush_all_caches()
 *
 * @return
 *   An array of cache table names.
 */
function hook_flush_caches() {
  return array('cache_example');
}

/**
 * Perform necessary actions after modules are installed.
 *
 * This function differs from hook_install() as it gives all other
 * modules a chance to perform actions when a module is installed,
 * whereas hook_install() will only be called on the module actually
 * being installed.
 *
 * @see hook_install()
 *
 * @param $modules
 *   An array of the installed modules.
 */
function hook_modules_installed($modules) {
  if (in_array('lousy_module', $modules)) {
    variable_set('lousy_module_conflicting_variable', FALSE);
  }
}

/**
 * Perform necessary actions after modules are enabled.
 *
 * This function differs from hook_enable() as it gives all other
 * modules a chance to perform actions when modules are enabled,
 * whereas hook_enable() will only be called on the module actually
 * being enabled.
 *
 * @see hook_enable()
 *
 * @param $modules
 *   An array of the enabled modules.
 */
function hook_modules_enabled($modules) {
  if (in_array('lousy_module', $modules)) {
    drupal_set_message(t('mymodule is not compatible with lousy_module'), 'error');
    mymodule_disable_functionality();
  }
}

/**
 * Perform necessary actions after modules are disabled.
 *
 * This function differs from hook_disable() as it gives all other
 * modules a chance to perform actions when modules are disabled,
 * whereas hook_disable() will only be called on the module actually
 * being disabled.
 *
 * @see hook_disable()
 *
 * @param $modules
 *   An array of the disabled modules.
 */
function hook_modules_disabled($modules) {
  if (in_array('lousy_module', $modules)) {
    mymodule_enable_functionality();
  }
}

/**
 * Perform necessary actions after modules are uninstalled.
 *
 * This function differs from hook_uninstall() as it gives all other
 * modules a chance to perform actions when a module is uninstalled,
 * whereas hook_uninstall() will only be called on the module actually
 * being uninstalled.
 *
 * It is recommended that you implement this module if your module
 * stores data that may have been set by other modules.
 *
 * @see hook_uninstall()
 *
 * @param $modules
 *   The name of the uninstalled module.
 */
function hook_modules_uninstalled($modules) {
  foreach ($modules as $module) {
    db_delete('mymodule_table')
      ->condition('module', $module)
      ->execute();
  }
  mymodule_cache_rebuild();
}

/**
 * custom_url_rewrite_outbound is not a hook, it's a function you can add to
 * settings.php to alter all links generated by Drupal. This function is called from url().
 * This function is called very frequently (100+ times per page) so performance is
 * critical.
 *
 * This function should change the value of $path and $options by reference.
 *
 * @param $path
 *   The alias of the $original_path as defined in the database.
 *   If there is no match in the database it'll be the same as $original_path
 * @param $options
 *   An array of link attributes such as querystring and fragment. See url().
 * @param $original_path
 *   The unaliased Drupal path that is being linked to.
 */
function custom_url_rewrite_outbound(&$path, &$options, $original_path) {
  global $user;

  // Change all 'node' to 'article'.
  if (preg_match('|^node(/.*)|', $path, $matches)) {
    $path = 'article' . $matches[1];
  }
  // Create a path called 'e' which lands the user on her profile edit page.
  if ($path == 'user/' . $user->uid . '/edit') {
    $path = 'e';
  }

}

/**
 * custom_url_rewrite_inbound is not a hook, it's a function you can add to
 * settings.php to alter incoming requests so they map to a Drupal path.
 * This function is called before modules are loaded and
 * the menu system is initialized and it changes $_GET['q'].
 *
 * This function should change the value of $result by reference.
 *
 * @param $result
 *   The Drupal path based on the database. If there is no match in the database it'll be the same as $path.
 * @param $path
 *   The path to be rewritten.
 * @param $path_language
 *   An optional language code to rewrite the path into.
 */
function custom_url_rewrite_inbound(&$result, $path, $path_language) {
  global $user;

  // Change all article/x requests to node/x
  if (preg_match('|^article(/.*)|', $path, $matches)) {
    $result = 'node' . $matches[1];
  }
  // Redirect a path called 'e' to the user's profile edit page.
  if ($path == 'e') {
    $result = 'user/' . $user->uid . '/edit';
  }
}

/**
 * Registers PHP stream wrapper implementations associated with a module.
 *
 * Provide a facility for managing and querying user-defined stream wrappers
 * in PHP. PHP's internal stream_get_wrappers() doesn't return the class
 * registered to handle a stream, which we need to be able to find the handler
 * for class instantiation.
 *
 * If a module registers a scheme that is already registered with PHP, it will
 * be unregistered and replaced with the specified class.
 *
 * @return
 *   A nested array, keyed first by scheme name ("public" for "public://"),
 *   then keyed by the following values:
 *   - 'name' A short string to name the wrapper.
 *   - 'class' A string specifying the PHP class that implements the
 *     DrupalStreamWrapperInterface interface.
 *   - 'description' A string with a short description of what the wrapper does.
 *
 * @see file_get_stream_wrappers()
 * @see hook_stream_wrappers_alter()
 * @see system_stream_wrappers()
 */
function hook_stream_wrappers() {
  return array(
    'public' => array(
      'name' => t('Public files'),
      'class' => 'DrupalPublicStreamWrapper',
      'description' => t('Public local files served by the webserver.'),
    ),
    'private' => array(
      'name' => t('Private files'),
      'class' => 'DrupalPrivateStreamWrapper',
      'description' => t('Private local files served by Drupal.'),
    ),
    'temp' => array(
      'name' => t('Temporary files'),
      'class' => 'DrupalTempStreamWrapper',
      'description' => t('Temporary local files for upload and previews.'),
    )
  );
}

/**
 * Alters the list of PHP stream wrapper implementations.
 *
 * @see file_get_stream_wrappers()
 * @see hook_stream_wrappers()
 */
function hook_stream_wrappers_alter(&$wrappers) {
  // Change the name of private files to reflect the performance.
  $wrappers['private']['name'] = t('Slow files');
}

/**
 * Load additional information into file objects.
 *
 * file_load_multiple() calls this hook to allow modules to load
 * additional information into each file.
 *
 * @param $files
 *   An array of file objects, indexed by fid.
 *
 * @see file_load_multiple()
 * @see upload_file_load()
 */
function hook_file_load($files) {
  // Add the upload specific data into the file object.
  $result = db_query('SELECT * FROM {upload} u WHERE u.fid IN (:fids)', array(':fids' => array_keys($files)))->fetchAll(PDO::FETCH_ASSOC);
  foreach ($result as $record) {
    foreach ($record as $key => $value) {
      $files[$record['fid']]->$key = $value;
    }
  }
}

/**
 * Check that files meet a given criteria.
 *
 * This hook lets modules perform additional validation on files. They're able
 * to report a failure by returning one or more error messages.
 *
 * @param $file
 *   The file object being validated.
 * @return
 *   An array of error messages. If there are no problems with the file return
 *   an empty array.
 *
 * @see file_validate()
 */
function hook_file_validate(&$file) {
  $errors = array();

  if (empty($file->filename)) {
    $errors[] = t("The file's name is empty. Please give a name to the file.");
  }
  if (strlen($file->filename) > 255) {
    $errors[] = t("The file's name exceeds the 255 characters limit. Please rename the file and try again.");
  }

  return $errors;
}

/**
 * Respond to a file being added.
 *
 * This hook is called when a file has been added to the database. The hook
 * doesn't distinguish between files created as a result of a copy or those
 * created by an upload.
 *
 * @param $file
 *   The file that has just been created.
 *
 * @see file_save()
 */
function hook_file_insert(&$file) {

}

/**
 * Respond to a file being updated.
 *
 * This hook is called when file_save() is called on an existing file.
 *
 * @param $file
 *   The file that has just been updated.
 *
 * @see file_save()
 */
function hook_file_update(&$file) {

}

/**
 * Respond to a file that has been copied.
 *
 * @param $file
 *   The newly copied file object.
 * @param $source
 *   The original file before the copy.
 *
 * @see file_copy()
 */
function hook_file_copy($file, $source) {

}

/**
 * Respond to a file that has been moved.
 *
 * @param $file
 *   The updated file object after the move.
 * @param $source
 *   The original file object before the move.
 *
 * @see file_move()
 */
function hook_file_move($file, $source) {

}

/**
 * Report the number of times a file is referenced by a module.
 *
 * This hook is called to determine if a files is in use. Multiple modules may
 * be referencing the same file and to prevent one from deleting a file used by
 * another this hook is called.
 *
 * @param $file
 *   The file object being checked for references.
 * @return
 *   If the module uses this file return an array with the module name as the
 *   key and the value the number of times the file is used.
 *
 * @see file_delete()
 * @see upload_file_references()
 */
function hook_file_references($file) {
  // If upload.module is still using a file, do not let other modules delete it.
  $file_used = (bool) db_query_range('SELECT 1 FROM {upload} WHERE fid = :fid', 0, 1, array(':fid' => $file->fid))->fetchField();
  if ($file_used) {
    // Return the name of the module and how many references it has to the file.
    return array('upload' => $count);
  }
}

/**
 * Respond to a file being deleted.
 *
 * @param $file
 *   The file that has just been deleted.
 *
 * @see file_delete()
 * @see upload_file_delete()
 */
function hook_file_delete($file) {
  // Delete all information associated with the file.
  db_delete('upload')->condition('fid', $file->fid)->execute();
}

/**
 * Control access to private file downloads and specify HTTP headers.
 *
 * This hook allows modules enforce permissions on file downloads when the
 * private file download method is selected. Modules can also provide headers
 * to specify information like the file's name or MIME type.
 *
 * @param $filepath
 *   String of the file's path.
 * @return
 *   If the user does not have permission to access the file, return -1. If the
 *   user has permission, return an array with the appropriate headers. If the
 *   file is not controlled by the current module, the return value should be
 *   NULL.
 *
 * @see file_download()
 * @see upload_file_download()
 */
function hook_file_download($filepath) {
  // Check if the file is controlled by the current module.
  if (!file_prepare_directory($filepath)) {
    $filepath = FALSE;
  }
  $result = db_query("SELECT f.* FROM {file} f INNER JOIN {upload} u ON f.fid = u.fid WHERE uri = :filepath", array('filepath' => $filepath));
  foreach ($result as $file) {
    if (!user_access('view uploaded files')) {
      return -1;
    }
    return array(
      'Content-Type' => $file->filemime,
      'Content-Length' => $file->filesize,
    );
  }
}

/**
 * Alter the URL to a file.
 *
 * This hook is called from file_create_url(), and  is called fairly
 * frequently (10+ times per page), depending on how many files there are in a
 * given page.
 * If CSS and JS aggregation are disabled, this can become very frequently
 * (50+ times per page) so performance is critical.
 *
 * This function should alter the URI, if it wants to rewrite the file URL.
 *
 * @param $uri
 *   The URI to a file for which we need an external URL, or the path to a
 *   shipped file.
 */
function hook_file_url_alter(&$uri) {
  global $user;

  // User 1 will always see the local file in this example.
  if ($user->uid == 1) {
    return;
  }

  $cdn1 = 'http://cdn1.example.com';
  $cdn2 = 'http://cdn2.example.com';
  $cdn_extensions = array('css', 'js', 'gif', 'jpg', 'jpeg', 'png');

  // Most CDNs don't support private file transfers without a lot of hassle,
  // so don't support this in the common case.
  $schemes = array('public');

  $scheme = file_uri_scheme($uri);

  // Only serve shipped files and public created files from the CDN.
  if (!$scheme || in_array($scheme, $schemes)) {
    // Shipped files.
    if (!$scheme) {
      $path = $uri;
    }
    // Public created files.
    else {
      $wrapper = file_stream_wrapper_get_instance_by_scheme($scheme);
      $path = $wrapper->getDirectoryPath() . '/' . file_uri_target($uri);
    }

    // Clean up Windows paths.
    $path = str_replace('\\', '/', $path);

    // Serve files with one of the CDN extensions from CDN 1, all others from
    // CDN 2.
    $pathinfo = pathinfo($path);
    if (array_key_exists('extension', $pathinfo) && in_array($pathinfo['extension'], $cdn_extensions)) {
      $uri = $cdn1 . '/' . $path;
    }
    else {
      $uri = $cdn2 . '/' . $path;
    }
  }
}
                                                                                                      /**
 * Check installation requirements and do status reporting.
 *
 * This hook has two closely related uses, determined by the $phase argument:
 * checking installation requirements ($phase == 'install')
 * and status reporting ($phase == 'runtime').
 *
 * Note that this hook, like all others dealing with installation and updates,
 * must reside in a module_name.install file, or it will not properly abort
 * the installation of the module if a critical requirement is missing.
 *
 * During the 'install' phase, modules can for example assert that
 * library or server versions are available or sufficient.
 * Note that the installation of a module can happen during installation of
 * Drupal itself (by install.php) with an installation profile or later by hand.
 * As a consequence, install-time requirements must be checked without access
 * to the full Drupal API, because it is not available during install.php.
 * For localization you should for example use $t = get_t() to
 * retrieve the appropriate localization function name (t() or st()).
 * If a requirement has a severity of REQUIREMENT_ERROR, install.php will abort
 * or at least the module will not install.
 * Other severity levels have no effect on the installation.
 * Module dependencies do not belong to these installation requirements,
 * but should be defined in the module's .info file.
 *
 * The 'runtime' phase is not limited to pure installation requirements
 * but can also be used for more general status information like maintenance
 * tasks and security issues.
 * The returned 'requirements' will be listed on the status report in the
 * administration section, with indication of the severity level.
 * Moreover, any requirement with a severity of REQUIREMENT_ERROR severity will
 * result in a notice on the the administration overview page.
 *
 * @param $phase
 *   The phase in which hook_requirements is run:
 *   - 'install': the module is being installed.
 *   - 'runtime': the runtime requirements are being checked and shown on the
 *              status report page.
 *
 * @return
 *   A keyed array of requirements. Each requirement is itself an array with
 *   the following items:
 *     - 'title': the name of the requirement.
 *     - 'value': the current value (e.g. version, time, level, ...). During
 *       install phase, this should only be used for version numbers, do not set
 *       it if not applicable.
 *     - 'description': description of the requirement/status.
 *     - 'severity': the requirement's result/severity level, one of:
 *         - REQUIREMENT_INFO:    For info only.
 *         - REQUIREMENT_OK:      The requirement is satisfied.
 *         - REQUIREMENT_WARNING: The requirement failed with a warning.
 *         - REQUIREMENT_ERROR:   The requirement failed with an error.
 */
function hook_requirements($phase) {
  $requirements = array();
  // Ensure translations don't break at install time
  $t = get_t();

  // Report Drupal version
  if ($phase == 'runtime') {
    $requirements['drupal'] = array(
      'title' => $t('Drupal'),
      'value' => VERSION,
      'severity' => REQUIREMENT_INFO
    );
  }

  // Test PHP version
  $requirements['php'] = array(
    'title' => $t('PHP'),
    'value' => ($phase == 'runtime') ? l(phpversion(), 'admin/logs/status/php') : phpversion(),
  );
  if (version_compare(phpversion(), DRUPAL_MINIMUM_PHP) < 0) {
    $requirements['php']['description'] = $t('Your PHP installation is too old. Drupal requires at least PHP %version.', array('%version' => DRUPAL_MINIMUM_PHP));
    $requirements['php']['severity'] = REQUIREMENT_ERROR;
  }

  // Report cron status
  if ($phase == 'runtime') {
    $cron_last = variable_get('cron_last');

    if (is_numeric($cron_last)) {
      $requirements['cron']['value'] = $t('Last run !time ago', array('!time' => format_interval(REQUEST_TIME - $cron_last)));
    }
    else {
      $requirements['cron'] = array(
        'description' => $t('Cron has not run. It appears cron jobs have not been setup on your system. Please check the help pages for <a href="@url">configuring cron jobs</a>.', array('@url' => 'http://drupal.org/cron')),
        'severity' => REQUIREMENT_ERROR,
        'value' => $t('Never run'),
      );
    }

    $requirements['cron']['description'] .= ' ' . t('You can <a href="@cron">run cron manually</a>.', array('@cron' => url('admin/logs/status/run-cron')));

    $requirements['cron']['title'] = $t('Cron maintenance tasks');
  }

  return $requirements;
}

/**
 * Define the current version of the database schema.
 *
 * A Drupal schema definition is an array structure representing one or
 * more tables and their related keys and indexes. A schema is defined by
 * hook_schema() which must live in your module's .install file.
 *
 * By implementing hook_schema() and specifying the tables your module
 * declares, you can easily create and drop these tables on all
 * supported database engines. You don't have to deal with the
 * different SQL dialects for table creation and alteration of the
 * supported database engines.
 *
 * See the Schema API Handbook at http://drupal.org/node/146843 for
 * details on schema definition structures.
 *
 * @return
 * A schema definition structure array. For each element of the
 * array, the key is a table name and the value is a table structure
 * definition.
 */
function hook_schema() {
  $schema['node'] = array(
    // example (partial) specification for table "node"
    'description' => 'The base table for nodes.',
    'fields' => array(
      'nid' => array(
        'description' => 'The primary identifier for a node.',
        'type' => 'serial',
        'unsigned' => TRUE,
        'not null' => TRUE),
      'vid' => array(
        'description' => 'The current {node_revision}.vid version identifier.',
        'type' => 'int',
        'unsigned' => TRUE,
        'not null' => TRUE,
        'default' => 0),
      'type' => array(
        'description' => 'The {node_type} of this node.',
        'type' => 'varchar',
        'length' => 32,
        'not null' => TRUE,
        'default' => ''),
      'title' => array(
        'description' => 'The title of this node, always treated a non-markup plain text.',
        'type' => 'varchar',
        'length' => 255,
        'not null' => TRUE,
        'default' => ''),
      ),
    'indexes' => array(
      'node_changed'        => array('changed'),
      'node_created'        => array('created'),
      ),
    'unique keys' => array(
      'nid_vid' => array('nid', 'vid'),
      'vid'     => array('vid')
      ),
    'primary key' => array('nid'),
  );
  return $schema;
}

/**
 * Perform alterations to existing database schemas.
 *
 * When a module modifies the database structure of another module (by
 * changing, adding or removing fields, keys or indexes), it should
 * implement hook_schema_alter() to update the default $schema to take
 * it's changes into account.
 *
 * See hook_schema() for details on the schema definition structure.
 *
 * @param $schema
 *   Nested array describing the schemas for all modules.
 */
function hook_schema_alter(&$schema) {
  // Add field to existing schema.
  $schema['users']['fields']['timezone_id'] = array(
    'type' => 'int',
    'not null' => TRUE,
    'default' => 0,
    'description' => 'Per-user timezone configuration.',
  );
}

/**
 * Perform alterations to a structured query.
 *
 * Structured (aka dynamic) queries that have tags associated may be altered by any module
 * before the query is executed.
 *
 * @see hook_query_TAG_alter()
 * @see node_query_node_access_alter()
 * @see QueryAlterableInterface
 * @see SelectQueryInterface
 * @param $query
 *   A Query object describing the composite parts of a SQL query.
 */
function hook_query_alter(QueryAlterableInterface $query) {
  if ($query->hasTag('micro_limit')) {
    $query->range(0, 2);
  }
}

/**
 * Perform alterations to a structured query for a given tag.
 *
 * @see hook_query_alter()
 * @see node_query_node_access_alter()
 * @see QueryAlterableInterface
 * @see SelectQueryInterface
 *
 * @param $query
 *   An Query object describing the composite parts of a SQL query.
 */
function hook_query_TAG_alter(QueryAlterableInterface $query) {
  // Skip the extra expensive alterations if site has no node access control modules.
  if (!node_access_view_all_nodes()) {
    // Prevent duplicates records.
    $query->distinct();
    // The recognized operations are 'view', 'update', 'delete'.
    if (!$op = $query->getMetaData('op')) {
      $op = 'view';
    }
    // Skip the extra joins and conditions for node admins.
    if (!user_access('bypass node access')) {
      // The node_access table has the access grants for any given node.
      $access_alias = $query->join('node_access', 'na', 'na.nid = n.nid');
      $or = db_or();
      // If any grant exists for the specified user, then user has access to the node for the specified operation.
      foreach (node_access_grants($op, $query->getMetaData('account')) as $realm => $gids) {
        foreach ($gids as $gid) {
          $or->condition(db_and()
            ->condition("{$access_alias}.gid", $gid)
            ->condition("{$access_alias}.realm", $realm)
          );
        }
      }

      if (count($or->conditions())) {
        $query->condition($or);
      }

      $query->condition("{$access_alias}.grant_$op", 1, '>=');
    }
  }
}

/**
 * Perform setup tasks when the module is installed.
 *
 * If the module implements hook_schema(), the database tables will
 * be created before this hook is fired.
 *
 * The hook will be called the first time a module is installed, and the
 * module's schema version will be set to the module's greatest numbered update
 * hook. Because of this, anytime a hook_update_N() is added to the module, this
 * function needs to be updated to reflect the current version of the database
 * schema.
 *
 * See the Schema API documentation at
 * @link http://drupal.org/node/146843 http://drupal.org/node/146843 @endlink
 * for details on hook_schema and how database tables are defined.
 *
 * Note that since this function is called from a full bootstrap, all functions
 * (including those in modules enabled by the current page request) are
 * available when this hook is called. Use cases could be displaying a user
 * message, or calling a module function necessary for initial setup, etc.
 *
 * Please be sure that anything added or modified in this function that can
 * be removed during uninstall should be removed with hook_uninstall().
 *
 * @see hook_uninstall()
 * @see hook_schema()
 */
function hook_install() {
  // Populate the default {node_access} record.
  db_insert('node_access')
    ->fields(array(
      'nid' => 0,
      'gid' => 0,
      'realm' => 'all',
      'grant_view' => 1,
      'grant_update' => 0,
      'grant_delete' => 0,
    ))
    ->execute();
}

/**
 * Perform a single update. For each patch which requires a database change add
 * a new hook_update_N() which will be called by update.php.
 *
 * The database updates are numbered sequentially according to the version of Drupal you are compatible with.
 *
 * Schema updates should adhere to the Schema API:
 * @link http://drupal.org/node/150215 http://drupal.org/node/150215 @endlink
 *
 * Database updates consist of 3 parts:
 * - 1 digit for Drupal core compatibility
 * - 1 digit for your module's major release version (e.g. is this the 5.x-1.* (1) or 5.x-2.* (2) series of your module?)
 * - 2 digits for sequential counting starting with 00
 *
 * The 2nd digit should be 0 for initial porting of your module to a new Drupal
 * core API.
 *
 * Examples:
 * - mymodule_update_5200()
 *   - This is the first update to get the database ready to run mymodule 5.x-2.*.
 * - mymodule_update_6000()
 *   - This is the required update for mymodule to run with Drupal core API 6.x.
 * - mymodule_update_6100()
 *   - This is the first update to get the database ready to run mymodule 6.x-1.*.
 * - mymodule_update_6200()
 *   - This is the first update to get the database ready to run mymodule 6.x-2.*.
 *     Users can directly update from 5.x-2.* to 6.x-2.* and they get all 60XX
 *     and 62XX updates, but not 61XX updates, because those reside in the
 *     6.x-1.x branch only.
 *
 * A good rule of thumb is to remove updates older than two major releases of
 * Drupal. See hook_update_last_removed() to notify Drupal about the removals.
 *
 * Never renumber update functions.
 *
 * Further information about releases and release numbers:
 * - @link http://drupal.org/handbook/version-info http://drupal.org/handbook/version-info @endlink
 * - @link http://drupal.org/node/93999 http://drupal.org/node/93999 @endlink (Overview of contributions branches and tags)
 * - @link http://drupal.org/handbook/cvs/releases http://drupal.org/handbook/cvs/releases @endlink
 *
 * Implementations of this hook should be placed in a mymodule.install file in
 * the same directory as mymodule.module. Drupal core's updates are implemented
 * using the system module as a name and stored in database/updates.inc.
 *
 * If your update task is potentially time-consuming, you'll need to implement a
 * multipass update to avoid PHP timeouts. Multipass updates use the $sandbox
 * parameter provided by the batch API (normally, $context['sandbox']) to store
 * information between successive calls, and the $ret['#finished'] return value
 * to provide feedback regarding completion level.
 *
 * See the batch operations page for more information on how to use the batch API:
 * @link http://drupal.org/node/146843 http://drupal.org/node/146843 @endlink
 *
 * @return An array with the results of the calls to update_sql(). An upate
 *   function can force the current and all later updates for this
 *   module to abort by returning a $ret array with an element like:
 *   $ret['#abort'] = array('success' => FALSE, 'query' => 'What went wrong');
 *   The schema version will not be updated in this case, and all the
 *   aborted updates will continue to appear on update.php as updates that
 *   have not yet been run. Multipass update functions will also want to pass
 *   back the $ret['#finished'] variable to inform the batch API of progress.
 */
function hook_update_N(&$sandbox = NULL) {
  // For most updates, the following is sufficient.
  $ret = array();
  db_add_field($ret, 'mytable1', 'newcol', array('type' => 'int', 'not null' => TRUE, 'description' => 'My new integer column.'));
  return $ret;

  // However, for more complex operations that may take a long time,
  // you may hook into Batch API as in the following example.
  $ret = array();

  // Update 3 users at a time to have an exclamation point after their names.
  // (They're really happy that we can do batch API in this hook!)
  if (!isset($sandbox['progress'])) {
    $sandbox['progress'] = 0;
    $sandbox['current_uid'] = 0;
    // We'll -1 to disregard the uid 0...
    $sandbox['max'] = db_query('SELECT COUNT(DISTINCT uid) FROM {users}')->fetchField() - 1;
  }
  db_select('users', 'u')
    ->fields('u', array('uid', 'name'))
    ->condition('uid', $sandbox['current_uid'], '>')
    ->range(0, 3)
    ->orderBy('uid', 'ASC')
    ->execute();
  foreach ($users as $user) {
    $user->name .= '!';
    $ret[] = update_sql("UPDATE {users} SET name = '$user->name' WHERE uid = $user->uid");

    $sandbox['progress']++;
    $sandbox['current_uid'] = $user->uid;
  }

  $ret['#finished'] = empty($sandbox['max']) ? 1 : ($sandbox['progress'] / $sandbox['max']);

  return $ret;
}

/**
 * Return a number which is no longer available as hook_update_N().
 *
 * If you remove some update functions from your mymodule.install file, you
 * should notify Drupal of those missing functions. This way, Drupal can
 * ensure that no update is accidentally skipped.
 *
 * Implementations of this hook should be placed in a mymodule.install file in
 * the same directory as mymodule.module.
 *
 * @return
 *   An integer, corresponding to hook_update_N() which has been removed from
 *   mymodule.install.
 *
 * @see hook_update_N()
 */
function hook_update_last_removed() {
  // We've removed the 5.x-1.x version of mymodule, including database updates.
  // The next update function is mymodule_update_5200().
  return 5103;
}

/**
 * Remove any information that the module sets.
 *
 * The information that the module should remove includes:
 * - variables that the module has set using variable_set() or system_settings_form()
 * - modifications to existing tables
 *
 * The module should not remove its entry from the {system} table. Database tables
 * defined by hook_schema() will be removed automatically.
 *
 * The uninstall hook will fire when the module gets uninstalled but before the
 * module's database tables are removed, allowing your module to query its own
 * tables during this routine.
 *
 * @see hook_install()
 * @see hook_schema()
 */
function hook_uninstall() {
  variable_del('upload_file_types');
}

/**
 * Perform necessary actions after module is enabled.
 *
 * The hook is called everytime module is enabled.
 */
function hook_enable() {
  mymodule_cache_rebuild();
}

/**
 * Perform necessary actions before module is disabled.
 *
 * The hook is called everytime module is disabled.
 */
function hook_disable() {
  mymodule_cache_rebuild();
}

/**
 * Perform necessary alterations to the list of files parsed by the registry.
 *
 * Modules can manually modify the list of files before the registry parses
 * them. The $modules array provides the .info file information, which includes
 * the list of files registered to each module. Any files in the list can then
 * be added to the list of files that the registry will parse, or modify
 * attributes of a file.
 *
 * A necessary alteration made by the core SimpleTest module is to force .test
 * files provided by disabled modules into the list of files parsed by the
 * registry.
 *
 * @param $files
 *   List of files to be parsed by the registry. The list will contain
 *   files found in each enabled module's info file and the core includes
 *   directory. The array is keyed by the file path and contains an array of
 *   the related module's name and weight as used internally by
 *   _registry_rebuild() and related functions.
 *
 *   For example:
 *   @code
 *     $files["modules/system/system.module"] = array(
 *       'module' => 'system',
 *       'weight' => 0,
 *     );
 *   @endcode
 * @param $modules
 *   List of all the modules provided as returned by drupal_system_listing().
 *   The list also contains the .info file information in the property 'info'.
 *   An additional 'dir' property has been added to the module information
 *   which provides the path to the directory in which the module resides. The
 *   example shows how to take advantage of the property both properties.
 *
 * @see _registry_rebuild()
 * @see drupal_system_listing()
 * @see simpletest_test_get_all()
 */
function hook_registry_files_alter(&$files, $module_cache) {
  foreach ($modules as $module) {
    // Only add test files for disabled modules, as enabled modules should
    // already include any test files they provide.
    if (!$module->status) {
      $dir = $module->dir;
      foreach ($module->info['files'] as $file) {
        if (substr($file, -5) == '.test') {
          $files["$dir/$file"] = array('module' => $module->name, 'weight' => $module->weight);
        }
      }
    }
  }
}

/**
 * Return an array of tasks to be performed by an installation profile.
 *
 * Any tasks you define here will be run, in order, after the installer has
 * finished the site configuration step but before it has moved on to the
 * final import of languages and the end of the installation. You can have any
 * number of custom tasks to perform during this phase.
 *
 * Each task you define here corresponds to a callback function which you must
 * separately define and which is called when your task is run. This function
 * will receive the global installation state variable, $install_state, as
 * input, and has the opportunity to access or modify any of its settings. See
 * the install_state_defaults() function in the installer for the list of
 * $install_state settings used by Drupal core.
 *
 * At the end of your task function, you can indicate that you want the
 * installer to pause and display a page to the user by returning any themed
 * output that should be displayed on that page (but see below for tasks that
 * use the form API or batch API; the return values of these task functions are
 * handled differently). You should also use drupal_set_title() within the task
 * callback function to set a custom page title. For some tasks, however, you
 * may want to simply do some processing and pass control to the next task
 * without ending the page request; to indicate this, simply do not send back
 * a return value from your task function at all. This can be used, for
 * example, by installation profiles that need to configure certain site
 * settings in the database without obtaining any input from the user.
 *
 * The task function is treated specially if it defines a form or requires
 * batch processing; in that case, you should return either the form API
 * definition or batch API array, as appropriate. See below for more
 * information on the 'type' key that you must define in the task definition
 * to inform the installer that your task falls into one of those two
 * categories. It is important to use these APIs directly, since the installer
 * may be run non-interactively (for example, via a command line script), all
 * in one page request; in that case, the installer will automatically take
 * care of submitting forms and processing batches correctly for both types of
 * installations. You can inspect the $install_state['interactive'] boolean to
 * see whether or not the current installation is interactive, if you need
 * access to this information.
 *
 * Remember that a user installing Drupal interactively will be able to reload
 * an installation page multiple times, so you should use variable_set() and
 * variable_get() if you are collecting any data that you need to store and
 * inspect later. It is important to remove any temporary variables using
 * variable_del() before your last task has completed and control is handed
 * back to the installer.
 *
 * @return
 *   A keyed array of tasks the profile will perform during the final stage of
 *   the installation. Each key represents the name of a function (usually a
 *   function defined by this profile, although that is not strictly required)
 *   that is called when that task is run. The values are associative arrays
 *   containing the following key-value pairs (all of which are optional):
 *     - 'display_name'
 *       The human-readable name of the task. This will be displayed to the
 *       user while the installer is running, along with a list of other tasks
 *       that are being run. Leave this unset to prevent the task from
 *       appearing in the list.
 *     - 'display'
 *       This is a boolean which can be used to provide finer-grained control
 *       over whether or not the task will display. This is mostly useful for
 *       tasks that are intended to display only under certain conditions; for
 *       these tasks, you can set 'display_name' to the name that you want to
 *       display, but then use this boolean to hide the task only when certain
 *       conditions apply.
 *     - 'type'
 *       A string representing the type of task. This parameter has three
 *       possible values:
 *       - 'normal': This indicates that the task will be treated as a regular
 *       callback function, which does its processing and optionally returns
 *       HTML output. This is the default behavior which is used when 'type' is
 *       not set.
 *       - 'batch': This indicates that the task function will return a batch
 *       API definition suitable for batch_set(). The installer will then take
 *       care of automatically running the task via batch processing.
 *       - 'form': This indicates that the task function will return a standard
 *       form API definition (and separately define validation and submit
 *       handlers, as appropriate). The installer will then take care of
 *       automatically directing the user through the form submission process.
 *     - 'run'
 *       A constant representing the manner in which the task will be run. This
 *       parameter has three possible values:
 *       - INSTALL_TASK_RUN_IF_NOT_COMPLETED: This indicates that the task will
 *       run once during the installation of the profile. This is the default
 *       behavior which is used when 'run' is not set.
 *       - INSTALL_TASK_SKIP: This indicates that the task will not run during
 *       the current installation page request. It can be used to skip running
 *       an installation task when certain conditions are met, even though the
 *       task may still show on the list of installation tasks presented to the
 *       user.
 *       - INSTALL_TASK_RUN_IF_REACHED: This indicates that the task will run
 *       on each installation page request that reaches it. This is rarely
 *       necessary for an installation profile to use; it is primarily used by
 *       the Drupal installer for bootstrap-related tasks.
 *     - 'function'
 *       Normally this does not need to be set, but it can be used to force the
 *       installer to call a different function when the task is run (rather
 *       than the function whose name is given by the array key). This could be
 *       used, for example, to allow the same function to be called by two
 *       different tasks.
 *
 * @see install_state_defaults()
 * @see batch_set()
 */
function hook_profile_tasks() {
  // Here, we define a variable to allow tasks to indicate that a particular,
  // processor-intensive batch process needs to be triggered later on in the
  // installation.
  $myprofile_needs_batch_processing = variable_get('myprofile_needs_batch_processing', FALSE);
  $tasks = array(
    // This is an example of a task that defines a form which the user who is
    // installing the site will be asked to fill out. To implement this task,
    // your profile would define a function named myprofile_data_import_form()
    // as a normal form API callback function, with associated validation and
    // submit handlers. In the submit handler, in addition to saving whatever
    // other data you have collected from the user, you might also call
    // variable_set('myprofile_needs_batch_processing', TRUE) if the user has
    // entered data which requires that batch processing will need to occur
    // later on.
    'myprofile_data_import_form' => array(
      'display_name' => st('Data import options'),
      'type' => 'form',
    ),
    // Similarly, to implement this task, your profile would define a function
    // named myprofile_settings_form() with associated validation and submit
    // handlers. This form might be used to collect and save additional
    // information from the user that your profile needs. There are no extra
    // steps required for your profile to act as an "installation wizard"; you
    // can simply define as many tasks of type 'form' as you wish to execute,
    // and the forms will be presented to the user, one after another.
    'myprofile_settings_form' => array(
      'display_name' => st('Additional options'),
      'type' => 'form',
    ),
    // This is an example of a task that performs batch operations. To
    // implement this task, your profile would define a function named
    // myprofile_batch_processing() which returns a batch API array definition
    // that the installer will use to execute your batch operations. Due to the
    // 'myprofile_needs_batch_processing' variable used here, this task will be
    // hidden and skipped unless your profile set it to TRUE in one of the
    // previous tasks.
    'myprofile_batch_processing' => array(
      'display_name' => st('Import additional data'),
      'display' => $myprofile_needs_batch_processing,
      'type' => 'batch',
      'run' => $myprofile_needs_batch_processing ? INSTALL_TASK_RUN_IF_NOT_COMPLETED : INSTALL_TASK_SKIP,
    ),
    // This is an example of a task that will not be displayed in the list that
    // the user sees. To implement this task, your profile would define a
    // function named myprofile_final_site_setup(), in which additional,
    // automated site setup operations would be performed. Since this is the
    // last task defined by your profile, you should also use this function to
    // call variable_del('myprofile_needs_batch_processing') and clean up the
    // variable that was used above. If you want the user to pass to the final
    // Drupal installation tasks uninterrupted, return no output from this
    // function. Otherwise, return themed output that the user will see (for
    // example, a confirmation page explaining that your profile's tasks are
    // complete, with a link to reload the current page and therefore pass on
    // to the final Drupal installation tasks when the user is ready to do so).
    'myprofile_final_site_setup' => array(
    ),
  );
  return $tasks;
}

/**
 * Change the page the user is sent to by drupal_goto().
 *
 * @param $args
 *   The array keys are the same as drupal_goto() arguments and the array can
 *   be changed.
 *   <code>
 *     $args = array(
 *       'path' => &$path,
 *       'query' => &$query,
 *       'fragment' => &$fragment,
 *       'http_response_code' => &$http_response_code,
 *     );
 *   </code>
 */
function hook_drupal_goto_alter(array $args) {
  // A good addition to misery module.
  $args['http_response_code'] = 500;
}

/**
 * Alter MIME type mappings used to determine MIME type from a file extension.
 *
 * This hook is run when file_mimetype_mapping() is called. It is used to
 * allow modules to add to or modify the default mapping from
 * file_default_mimetype_mapping().
 *
 * @param $mapping
 *   An array of mimetypes correlated to the extensions that relate to them.
 *   The array has 'mimetypes' and 'extensions' elements, each of which is an
 *   array.
 * @see file_default_mimetype_mapping()
 */
function hook_file_mimetype_mapping_alter(&$mapping) {
  // Add new MIME type 'drupal/info'.
  $mapping['mimetypes']['example_info'] = 'drupal/info';
  // Add new extension '.info' and map it to the 'drupal/info' MIME type.
  $mapping['extensions']['info'] = 'example_info';
  // Override existing extension mapping for '.ogg' files.
  $mapping['extensions']['ogg'] = 189;
}

/**
 * Declares information about actions.
 *
 * Any module can define actions, and then call actions_do() to make those
 * actions happen in response to events. The trigger module provides a user
 * interface for associating actions with module-defined triggers, and it makes
 * sure the core triggers fire off actions when their events happen.
 *
 * An action consists of two or three parts:
 * - an action definition (returned by this hook)
 * - a function which performs the action (which by convention is named
 *   MODULE_description-of-function_action)
 * - an optional form definition function that defines a configuration form
 *   (which has the name of the action function with '_form' appended to it.)
 *
 * The action function takes two to four arguments, which come from the input
 * arguments to actions_do().
 *
 * @return
 *   An associative array of action descriptions. The keys of the array
 *   are the names of the action functions, and each corresponding value
 *   is an associative array with the following key-value pairs:
 *   - 'type': The type of object this action acts upon. Core actions have types
 *     'node', 'user', 'comment', and 'system'.
 *   - 'label': The human-readable name of the action, which should be passed
 *     through the t() function for translation.
 *   - 'configurable': If FALSE, then the action doesn't require any extra
 *     configuration. If TRUE, then your module must define a form function with
 *     the same name as the action function with '_form' appended (e.g., the
 *     form for 'node_assign_owner_action' is 'node_assign_owner_action_form'.)
 *     This function takes $context as its only parameter, and is paired with
 *     the usual _submit function, and possibly a _validate function.
 *   - 'triggers': An array of the events (that is, hooks) that can trigger this
 *     action. For example: array('node_insert', 'user_update'). You can also
 *     declare support for any trigger by returning array('any') for this value.
 *   - 'behavior': (optional) machine-readable array of behaviors of this
 *     action, used to signal additional actions that may need to be triggered.
 *     Currently recognized behaviors by Trigger module:
 *     - 'changes_node_property': If an action with this behavior is assigned to
 *       a trigger other than 'node_presave', any node save actions also
 *       assigned to this trigger are moved later in the list. If a node save
 *       action is not present, one will be added.
 */
function hook_action_info() {
  return array(
    'comment_unpublish_action' => array(
      'type' => 'comment',
      'label' => t('Unpublish comment'),
      'configurable' => FALSE,
      'triggers' => array('comment_insert', 'comment_update'),
    ),
    'comment_unpublish_by_keyword_action' => array(
      'type' => 'comment',
      'label' => t('Unpublish comment containing keyword(s)'),
      'configurable' => TRUE,
      'triggers' => array('comment_insert', 'comment_update'),
    ),
  );
}

/**
 * Executes code after an action is deleted.
 *
 * @param $aid
 *   The action ID.
 */
function hook_actions_delete($aid) {
  db_delete('actions_assignments')
    ->condition('aid', $aid)
    ->execute();
}

/**
 * Alters the actions declared by another module.
 *
 * Called by actions_list() to allow modules to alter the return values from
 * implementations of hook_action_info().
 *
 * @see trigger_example_action_info_alter().
 */
function hook_action_info_alter(&$actions) {
  $actions['node_unpublish_action']['label'] = t('Unpublish and remove from public view.');
}

/**
 * @} End of "addtogroup hooks".
 */
