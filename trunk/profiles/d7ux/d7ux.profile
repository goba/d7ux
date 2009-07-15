<?php

/**
 * Implement hook_profile_tasks().
 */
function d7ux_profile_tasks(&$task, $url) {
  
  // Enable some standard blocks.
  $values = array(
    array(
      'module' => 'system',
      'delta' => 'main',
      'theme' => 'garland',
      'status' => 1,
      'weight' => 0,
      'region' => 'content',
      'pages' => '',
      'cache' => -1,
      'custom' => 0,
    ),
    array(
      'module' => 'user',
      'delta' => 'login',
      'theme' => 'garland',
      'status' => 1,
      'weight' => 0,
      'region' => 'left',
      'pages' => '',
      'cache' => -1,
      'custom' => 0,
    ),
    array(
      'module' => 'system',
      'delta' => 'navigation',
      'theme' => 'garland',
      'status' => 1,
      'weight' => 0,
      'region' => 'left',
      'pages' => '',
      'cache' => -1,
      'custom' => 0,
    ),
    array(
      'module' => 'system',
      'delta' => 'powered-by',
      'theme' => 'garland',
      'status' => 1,
      'weight' => 10,
      'region' => 'footer',
      'pages' => '',
      'cache' => -1,
      'custom' => 0,
    ),
    array(
      'module' => 'system',
      'delta' => 'help',
      'theme' => 'garland',
      'status' => 1,
      'weight' => 0,
      'region' => 'help',
      'pages' => '',
      'cache' => -1,
      'custom' => 0,
    ),
    array(
      'module' => 'system',
      'delta' => 'main',
      'theme' => 'slate',
      'status' => 1,
      'weight' => 0,
      'region' => 'content',
      'pages' => '',
      'cache' => -1,
      'custom' => 0,
    ),
  );
  $query = db_insert('block')->fields(array('module', 'delta', 'theme', 'status', 'weight', 'region', 'pages', 'cache', 'custom'));
  foreach ($values as $record) {
    $query->values($record);
  }
  $query->execute();  

  // Insert default user-defined node types into the database. For a complete
  // list of available node type attributes, refer to the node type API
  // documentation at: http://api.drupal.org/api/HEAD/function/hook_node_info.
  $types = array(
    array(
      'type' => 'page',
      'name' => st('Page'),
      'base' => 'node_content',
      'description' => st("A <em>page</em>, similar in form to an <em>article</em>, is a simple method for creating and displaying information that rarely changes, such as an \"About us\" section of a website. By default, a <em>page</em> entry does not allow visitor comments and is not featured on the site's initial home page."),
      'custom' => 1,
      'modified' => 1,
      'locked' => 0,
    ),
    array(
      'type' => 'article',
      'name' => st('Article'),
      'base' => 'node_content',
      'description' => st("An <em>article</em>, similar in form to a <em>page</em>, is ideal for creating and displaying content that informs or engages website visitors. Press releases, site announcements, and informal blog-like entries may all be created with an <em>article</em> entry. By default, an <em>article</em> entry is automatically featured on the site's initial home page, and provides the ability to post comments."),
      'custom' => 1,
      'modified' => 1,
      'locked' => 0,
    ),
  );

  foreach ($types as $type) {
    $type = node_type_set_defaults($type);
    node_type_save($type);
  }

  // Default page to not be promoted and have comments disabled.
  variable_set('node_options_page', array('status'));
  variable_set('comment_page', COMMENT_NODE_HIDDEN);

  // Don't display date and author information for page nodes by default.
  variable_set('node_submitted_page', FALSE);

  // Create a default vocabulary named "Tags", enabled for the 'article' content type.
  $description = st('Use tags to group articles on similar topics into categories.');
  $help = st('Enter a comma-separated list of words.');

  $vid = db_insert('taxonomy_vocabulary')->fields(array(
    'name' => 'Tags',
    'description' => $description,
    'help' => $help,
    'relations' => 0,
    'hierarchy' => 0,
    'multiple' => 0,
    'required' => 0,
    'tags' => 1,
    'module' => 'taxonomy',
    'weight' => 0,
  ))->execute();
  db_insert('taxonomy_vocabulary_node_type')->fields(array('vid' => $vid, 'type' => 'article'))->execute();

  // Create a default role for site administrators.
  $rid = db_insert('role')->fields(array('name' => 'administrator'))->execute();

  // Set this as the administrator role.
  variable_set('user_admin_role', $rid);

  // Assign all available permissions to this role.
  foreach (module_invoke_all('perm') as $key => $value) {
    db_insert('role_permission')
      ->fields(array(
        'rid' => $rid,
        'permission' => $key,
      ))->execute();
  }

  // Update the menu router information.
  menu_rebuild();

  // Save some default links.
  $link = array('link_path' => 'admin/build/menu-customize/main-menu/add', 'link_title' => 'Add a main menu link', 'menu_name' => 'main-menu');
  menu_link_save($link);
  
  // Tell the popups module to always scan for popup links.
  variable_set('popups_always_scan', 1);
  // Set popups to unskinned.
  variable_set('popups_skin', 'D7ux');
  
  // Enable the admin theme.
  db_update('system')
    ->fields(array('status' => 1))
    ->condition('type', 'theme')
    ->condition('name', 'slate')
    ->execute();
  variable_set('admin_theme', 'slate');
  variable_set('node_admin_theme', '1');
}

/**
 * Implement hook_form_alter().
 *
 * Allows the profile to alter the site-configuration form. This is
 * called through custom invocation, so $form_state is not populated.
 */
function d7ux_form_alter(&$form, $form_state, $form_id) {
  if ($form_id == 'install_configure') {
    // Set default for site name field.
    $form['site_information']['site_name']['#default_value'] = $_SERVER['SERVER_NAME'];
  }
}
