<?php
// $Id: node.pages.inc,v 1.82 2009/09/25 14:24:34 dries Exp $

/**
 * @file
 * Page callbacks for adding, editing, deleting, and revisions management for content.
 */


/**
 * Menu callback; presents the node editing form, or redirects to delete confirmation.
 */
function node_page_edit($node) {
  $type_name = node_type_get_name($node);
  drupal_set_title(t('<em>Edit @type</em> @title', array('@type' => $type_name, '@title' => $node->title)), PASS_THROUGH);
  return drupal_get_form($node->type . '_node_form', $node);
}

function node_add_page() {
  $item = menu_get_item();
  $content = system_admin_menu_block($item);
  // Bypass the node/add listing if only one content type is available.
  if (count($content) == 1) {
    $item = array_shift($content);
    drupal_goto($item['href']);
  }
  return theme('node_add_list', $content);
}

/**
 * Display the list of available node types for node creation.
 *
 * @ingroup themeable
 */
function theme_node_add_list($content) {
  $output = '';

  if ($content) {
    $output = '<dl class="node-type-list">';
    foreach ($content as $item) {
      $output .= '<dt>' . l($item['title'], $item['href'], $item['localized_options']) . '</dt>';
      $output .= '<dd>' . filter_xss_admin($item['description']) . '</dd>';
    }
    $output .= '</dl>';
  }
  else {
    $output = '<p>' . t('You have not created any content types yet. Please go to the <a href="@create-content">content type creation page</a> to add a new content type.', array('@create-content' => url('admin/structure/types/add'))) . '</p>';
  }
  return $output;
}


/**
 * Present a node submission form or a set of links to such forms.
 */
function node_add($type) {
  global $user;

  $types = node_type_get_types();
  $type = isset($type) ? str_replace('-', '_', $type) : NULL;
  // If a node type has been specified, validate its existence.
  if (isset($types[$type]) && node_access('create', $type)) {
    // Initialize settings:
    $node = array('uid' => $user->uid, 'name' => (isset($user->name) ? $user->name : ''), 'type' => $type, 'language' => '');

    drupal_set_title(t('Create @name', array('@name' => $types[$type]->name)), PASS_THROUGH);
    $output = drupal_get_form($type . '_node_form', $node);
  }

  return $output;
}

function node_form_validate($form, &$form_state) {
  $node = $form_state['values'];
  node_validate($node, $form);

  // Field validation. Requires access to $form_state, so this cannot be
  // done in node_validate() as it currently exists.
  $node = (object)$node;
  field_attach_form_validate('node', $node, $form, $form_state);
}

function node_object_prepare($node) {
  // Set up default values, if required.
  $node_options = variable_get('node_options_' . $node->type, array('status', 'promote'));
  // If this is a new node, fill in the default values.
  if (!isset($node->nid)) {
    foreach (array('status', 'promote', 'sticky') as $key) {
      $node->$key = in_array($key, $node_options);
    }
    global $user;
    $node->uid = $user->uid;
    $node->created = REQUEST_TIME;
  }
  else {
    $node->date = format_date($node->created, 'custom', 'Y-m-d H:i:s O');
    // Remove the log message from the original node object.
    $node->log = NULL;
  }
  // Always use the default revision setting.
  $node->revision = in_array('revision', $node_options);

  node_invoke($node, 'prepare');
  module_invoke_all('node_prepare', $node);
}

/**
 * Generate the node add/edit form array.
 */
function node_form($form, &$form_state, $node) {
  global $user;

  if (isset($form_state['node'])) {
    $node = $form_state['node'] + (array)$node;
  }
  if (isset($form_state['node_preview'])) {
    $form['#prefix'] = $form_state['node_preview'];
  }
  $node = (object)$node;
  foreach (array('title') as $key) {
    if (!isset($node->$key)) {
      $node->$key = NULL;
    }
  }
  if (!isset($form_state['node_preview'])) {
    node_object_prepare($node);
  }
  else {
    $node->in_preview = TRUE;
  }

  // Set the id and identify this as a node edit form.
  $form['#id'] = 'node-form';
  $form['#node_edit_form'] = TRUE;

  // Basic node information.
  // These elements are just values so they are not even sent to the client.
  foreach (array('nid', 'vid', 'uid', 'created', 'type', 'language') as $key) {
    $form[$key] = array(
      '#type' => 'value',
      '#value' => isset($node->$key) ? $node->$key : NULL,
    );
  }

  // Changed must be sent to the client, for later overwrite error checking.
  $form['changed'] = array(
    '#type' => 'hidden',
    '#default_value' => isset($node->changed) ? $node->changed : NULL,
  );
  // Get the node-specific bits.
  if ($extra = node_invoke($node, 'form', $form_state)) {
    $form = array_merge_recursive($form, $extra);
  }
  if (!isset($form['title']['#weight'])) {
    $form['title']['#weight'] = -5;
  }

  $form['#node'] = $node;

  $form['additional_settings'] = array(
    '#type' => 'vertical_tabs',
    '#weight' => 99,
  );

  // Add a log field if the "Create new revision" option is checked, or if the
  // current user has the ability to check that option.
  if (!empty($node->revision) || user_access('administer nodes')) {
    $form['revision_information'] = array(
      '#type' => 'fieldset',
      '#title' => t('Revision information'),
      '#collapsible' => TRUE,
      // Collapsed by default when "Create new revision" is unchecked
      '#collapsed' => !$node->revision,
      '#group' => 'additional_settings',
      '#attached' => array(
        'js' => array(drupal_get_path('module', 'node') . '/node.js'),
      ),
      '#weight' => 20,
    );
    $form['revision_information']['revision'] = array(
      '#access' => user_access('administer nodes'),
      '#type' => 'checkbox',
      '#title' => t('Create new revision'),
      '#default_value' => $node->revision,
    );
    $form['revision_information']['log'] = array(
      '#type' => 'textarea',
      '#title' => t('Revision log message'),
      '#rows' => 4,
      '#default_value' => !empty($node->log) ? $node->log : '',
      '#description' => t('Provide an explanation of the changes you are making. This will help other authors understand your motivations.'),
    );
  }

  // Node author information for administrators
  $form['author'] = array(
    '#type' => 'fieldset',
    '#access' => user_access('administer nodes'),
    '#title' => t('Authoring information'),
    '#collapsible' => TRUE,
    '#collapsed' => TRUE,
    '#group' => 'additional_settings',
    '#attached' => array(
      'js' => array(drupal_get_path('module', 'node') . '/node.js'),
    ),
    '#weight' => 90,
  );
  $form['author']['name'] = array(
    '#type' => 'textfield',
    '#title' => t('Authored by'),
    '#maxlength' => 60,
    '#autocomplete_path' => 'user/autocomplete',
    '#default_value' => !empty($node->name) ? $node->name : '',
    '#weight' => -1,
    '#description' => t('Leave blank for %anonymous.', array('%anonymous' => variable_get('anonymous', t('Anonymous')))),
  );
  $form['author']['date'] = array(
    '#type' => 'textfield',
    '#title' => t('Authored on'),
    '#maxlength' => 25,
    '#description' => t('Format: %time. The date format is YYYY-MM-DD and %timezone is the timezone offset from UTC. Leave blank to use the time of form submission.', array('%time' => !empty($node->date) ? $node->date : format_date($node->created, 'custom', 'Y-m-d H:i:s O'), '%timezone' => !empty($node->date) ? $node->date : format_date($node->created, 'custom', 'O'))),
  );

  if (isset($node->date)) {
    $form['author']['date']['#default_value'] = $node->date;
  }

  // Node options for administrators
  $form['options'] = array(
    '#type' => 'fieldset',
    '#access' => user_access('administer nodes'),
    '#title' => t('Publishing options'),
    '#collapsible' => TRUE,
    '#collapsed' => TRUE,
    '#group' => 'additional_settings',
    '#attached' => array(
      'js' => array(drupal_get_path('module', 'node') . '/node.js'),
    ),
    '#weight' => 95,
  );
  $form['options']['status'] = array(
    '#type' => 'checkbox',
    '#title' => t('Published'),
    '#default_value' => $node->status,
  );
  $form['options']['promote'] = array(
    '#type' => 'checkbox',
    '#title' => t('Promoted to front page'),
    '#default_value' => $node->promote,
  );
  $form['options']['sticky'] = array(
    '#type' => 'checkbox',
    '#title' => t('Sticky at top of lists'),
    '#default_value' => $node->sticky,
  );

  // These values are used when the user has no administrator access.
  foreach (array('uid', 'created') as $key) {
    $form[$key] = array(
      '#type' => 'value',
      '#value' => $node->$key,
    );
  }

  // Add the buttons.
  $form['buttons'] = array();
  $form['buttons']['#weight'] = 100;
  $form['buttons']['submit'] = array(
    '#type' => 'submit',
    '#access' => variable_get('node_preview_' . $node->type, 1) != DRUPAL_REQUIRED || (!form_get_errors() && isset($form_state['node_preview'])),
    '#value' => t('Save'),
    '#weight' => 5,
    '#submit' => array('node_form_submit'),
  );
  $form['buttons']['preview'] = array(
    '#access' => variable_get('node_preview_' . $node->type, 1) != DRUPAL_DISABLED,
    '#type' => 'submit',
    '#value' => t('Preview'),
    '#weight' => 10,
    '#submit' => array('node_form_build_preview'),
  );
  if (!empty($node->nid) && node_access('delete', $node)) {
    $form['buttons']['delete'] = array(
      '#type' => 'submit',
      '#value' => t('Delete'),
      '#weight' => 15,
      '#submit' => array('node_form_delete_submit'),
    );
  }
  $form['#validate'][] = 'node_form_validate';
  $form['#theme'] = array($node->type . '_node_form', 'node_form');

  $form['#builder_function'] = 'node_form_submit_build_node';
  field_attach_form('node', $node, $form, $form_state, $node->language);

  return $form;
}

/**
 * Button submit function: handle the 'Delete' button on the node form.
 */
function node_form_delete_submit($form, &$form_state) {
  $destination = '';
  if (isset($_GET['destination'])) {
    $destination = drupal_get_destination();
    unset($_GET['destination']);
  }
  $node = $form['#node'];
  $form_state['redirect'] = array('node/' . $node->nid . '/delete', $destination);
}


function node_form_build_preview($form, &$form_state) {
  $node = node_form_submit_build_node($form, $form_state);
  $form_state['node_preview'] = node_preview($node);
}

/**
 * Present a node submission form.
 *
 * @ingroup themeable
 */
function theme_node_form($form) {
  $output = "\n<div class=\"node-form\">\n";

  $output .= "  <div class=\"standard\">\n";
  $output .= drupal_render_children($form);
  $output .= "  </div>\n";

  $output .= "</div>\n";

  return $output;
}

/**
 * Generate a node preview.
 */
function node_preview($node) {
  if (node_access('create', $node) || node_access('update', $node)) {
    _field_invoke_multiple('load', 'node', array($node->nid => $node));
    // Load the user's name when needed.
    if (isset($node->name)) {
      // The use of isset() is mandatory in the context of user IDs, because
      // user ID 0 denotes the anonymous user.
      if ($user = user_load_by_name($node->name)) {
        $node->uid = $user->uid;
        $node->picture = $user->picture;
      }
      else {
        $node->uid = 0; // anonymous user
      }
    }
    elseif ($node->uid) {
      $user = user_load($node->uid);
      $node->name = $user->name;
      $node->picture = $user->picture;
    }

    $node->changed = REQUEST_TIME;

    // Display a preview of the node.
    // Previewing alters $node so it needs to be cloned.
    if (!form_get_errors()) {
      $cloned_node = clone $node;
      $cloned_node->in_preview = TRUE;
      $output = theme('node_preview', $cloned_node);
    }
    drupal_set_title(t('Preview'), PASS_THROUGH);

    return $output;
  }
}

/**
 * Display a node preview for display during node creation and editing.
 *
 * @param $node
 *   The node object which is being previewed.
 *
 * @ingroup themeable
 */
function theme_node_preview($node) {
  $output = '<div class="preview">';

  $preview_trimmed_version = FALSE;

  $trimmed = drupal_render(node_build(clone $node, 'teaser'));
  $full = drupal_render(node_build($node, 'full'));

  // Do we need to preview trimmed version of post as well as full version?
  if ($trimmed != $full) {
    drupal_set_message(t('The trimmed version of your post shows what your post looks like when promoted to the main page or when exported for syndication.<span class="no-js"> You can insert the delimiter "&lt;!--break--&gt;" (without the quotes) to fine-tune where your post gets split.</span>'));
    $output .= '<h3>' . t('Preview trimmed version') . '</h3>';
    $output .= $trimmed;
    $output .= '<h3>' . t('Preview full version') . '</h3>';
    $output .= $full;
  }
  else {
    $output .= $full;
  }
  $output .= "</div>\n";

  return $output;
}

function node_form_submit($form, &$form_state) {
  global $user;

  $node = node_form_submit_build_node($form, $form_state);
  $insert = empty($node->nid);
  node_save($node);
  $node_link = l(t('view'), 'node/' . $node->nid);
  $watchdog_args = array('@type' => $node->type, '%title' => $node->title);
  $t_args = array('@type' => node_type_get_name($node), '%title' => $node->title);

  if ($insert) {
    watchdog('content', '@type: added %title.', $watchdog_args, WATCHDOG_NOTICE, $node_link);
    drupal_set_message(t('@type %title has been created.', $t_args));
  }
  else {
    watchdog('content', '@type: updated %title.', $watchdog_args, WATCHDOG_NOTICE, $node_link);
    drupal_set_message(t('@type %title has been updated.', $t_args));
  }
  if ($node->nid) {
    unset($form_state['rebuild']);
    $form_state['nid'] = $node->nid;
    $form_state['redirect'] = 'node/' . $node->nid;
  }
  else {
    // In the unlikely case something went wrong on save, the node will be
    // rebuilt and node form redisplayed the same way as in preview.
    drupal_set_message(t('The post could not be saved.'), 'error');
  }
}

/**
 * Build a node by processing submitted form values and prepare for a form rebuild.
 */
function node_form_submit_build_node($form, &$form_state) {
  // Unset any button-level handlers, execute all the form-level submit
  // functions to process the form values into an updated node.
  unset($form_state['submit_handlers']);
  form_execute_handlers('submit', $form, $form_state);
  $node = node_submit($form_state['values']);

  field_attach_submit('node', $node, $form, $form_state);

  $form_state['node'] = (array)$node;
  $form_state['rebuild'] = TRUE;
  return $node;
}

/**
 * Menu callback -- ask for confirmation of node deletion
 */
function node_delete_confirm($form, &$form_state, $node) {
  $form['nid'] = array(
    '#type' => 'value',
    '#value' => $node->nid,
  );

  return confirm_form($form,
    t('Are you sure you want to delete %title?', array('%title' => $node->title)),
    isset($_GET['destination']) ? $_GET['destination'] : 'node/' . $node->nid,
    t('This action cannot be undone.'),
    t('Delete'),
    t('Cancel')
  );
}

/**
 * Execute node deletion
 */
function node_delete_confirm_submit($form, &$form_state) {
  if ($form_state['values']['confirm']) {
    $node = node_load($form_state['values']['nid']);
    node_delete($form_state['values']['nid']);
    watchdog('content', '@type: deleted %title.', array('@type' => $node->type, '%title' => $node->title));
    drupal_set_message(t('@type %title has been deleted.', array('@type' => node_type_get_name($node), '%title' => $node->title)));
  }

  $form_state['redirect'] = '<front>';
}

/**
 * Generate an overview table of older revisions of a node.
 */
function node_revision_overview($node) {
  drupal_set_title(t('Revisions for %title', array('%title' => $node->title)), PASS_THROUGH);

  $header = array(t('Revision'), array('data' => t('Operations'), 'colspan' => 2));

  $revisions = node_revision_list($node);

  $rows = array();
  $revert_permission = FALSE;
  if ((user_access('revert revisions') || user_access('administer nodes')) && node_access('update', $node)) {
    $revert_permission = TRUE;
  }
  $delete_permission = FALSE;
  if ((user_access('delete revisions') || user_access('administer nodes')) && node_access('delete', $node)) {
    $delete_permission = TRUE;
  }
  foreach ($revisions as $revision) {
    $row = array();
    $operations = array();

    if ($revision->current_vid > 0) {
      $row[] = array('data' => t('!date by !username', array('!date' => l(format_date($revision->timestamp, 'short'), "node/$node->nid"), '!username' => theme('username', $revision)))
                               . (($revision->log != '') ? '<p class="revision-log">' . filter_xss($revision->log) . '</p>' : ''),
                     'class' => array('revision-current'));
      $operations[] = array('data' => theme('placeholder', t('current revision')), 'class' => array('revision-current'), 'colspan' => 2);
    }
    else {
      $row[] = t('!date by !username', array('!date' => l(format_date($revision->timestamp, 'short'), "node/$node->nid/revisions/$revision->vid/view"), '!username' => theme('username', $revision)))
               . (($revision->log != '') ? '<p class="revision-log">' . filter_xss($revision->log) . '</p>' : '');
      if ($revert_permission) {
        $operations[] = l(t('revert'), "node/$node->nid/revisions/$revision->vid/revert");
      }
      if ($delete_permission) {
        $operations[] = l(t('delete'), "node/$node->nid/revisions/$revision->vid/delete");
      }
    }
    $rows[] = array_merge($row, $operations);
  }
  
  $build['node_revisions_table'] = array(
    '#theme' => 'table',
    '#rows' => $rows,
    '#header' => $header,
  );

  return $build;
}

/**
 * Ask for confirmation of the reversion to prevent against CSRF attacks.
 */
function node_revision_revert_confirm($form, $form_state, $node_revision) {
  $form['#node_revision'] = $node_revision;
  return confirm_form($form, t('Are you sure you want to revert to the revision from %revision-date?', array('%revision-date' => format_date($node_revision->revision_timestamp))), 'node/' . $node_revision->nid . '/revisions', '', t('Revert'), t('Cancel'));
}

function node_revision_revert_confirm_submit($form, &$form_state) {
  $node_revision = $form['#node_revision'];
  $node_revision->revision = 1;
  $node_revision->log = t('Copy of the revision from %date.', array('%date' => format_date($node_revision->revision_timestamp)));
  if (module_exists('taxonomy')) {
    $node_revision->taxonomy = array_keys($node_revision->taxonomy);
  }

  node_save($node_revision);

  watchdog('content', '@type: reverted %title revision %revision.', array('@type' => $node_revision->type, '%title' => $node_revision->title, '%revision' => $node_revision->vid));
  drupal_set_message(t('@type %title has been reverted back to the revision from %revision-date.', array('@type' => node_type_get_name($node_revision), '%title' => $node_revision->title, '%revision-date' => format_date($node_revision->revision_timestamp))));
  $form_state['redirect'] = 'node/' . $node_revision->nid . '/revisions';
}

function node_revision_delete_confirm($form, $form_state, $node_revision) {
  $form['#node_revision'] = $node_revision;
  return confirm_form($form, t('Are you sure you want to delete the revision from %revision-date?', array('%revision-date' => format_date($node_revision->revision_timestamp))), 'node/' . $node_revision->nid . '/revisions', t('This action cannot be undone.'), t('Delete'), t('Cancel'));
}

function node_revision_delete_confirm_submit($form, &$form_state) {
  $node_revision = $form['#node_revision'];
  node_revision_delete($node_revision->vid);

  watchdog('content', '@type: deleted %title revision %revision.', array('@type' => $node_revision->type, '%title' => $node_revision->title, '%revision' => $node_revision->vid));
  drupal_set_message(t('Revision from %revision-date of @type %title has been deleted.', array('%revision-date' => format_date($node_revision->revision_timestamp), '@type' => node_type_get_name($node_revision), '%title' => $node_revision->title)));
  $form_state['redirect'] = 'node/' . $node_revision->nid;
  if (db_query('SELECT COUNT(vid) FROM {node_revision} WHERE nid = :nid', array(':nid' => $node_revision->nid))->fetchField() > 1) {
    $form_state['redirect'] .= '/revisions';
  }
}
