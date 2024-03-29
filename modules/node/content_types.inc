<?php
// $Id: content_types.inc,v 1.94 2009/09/18 00:12:47 webchick Exp $

/**
 * @file
 * Content type editing UI.
 */

/**
 * Displays the content type admin overview page.
 */
function node_overview_types() {
  $types = node_type_get_types();
  $names = node_type_get_names();
  $header = array(t('Name'), array('data' => t('Operations'), 'colspan' => '2'));
  $rows = array();

  foreach ($names as $key => $name) {
    $type = $types[$key]; 
    if (node_hook($type->type, 'form')) {
      $type_url_str = str_replace('_', '-', $type->type);
      $row = array(theme('node_admin_overview', $name, $type));
      // Set the edit column.
      $row[] = array('data' => l(t('edit'), 'admin/structure/node-type/' . $type_url_str));

      // Set the delete column.
      if ($type->custom) {
        $row[] = array('data' => l(t('delete'), 'admin/structure/node-type/' . $type_url_str . '/delete'));
      }
      else {
        $row[] = array('data' => '');
      }
      $rows[] = $row;
    }
  }

  if (empty($rows)) {
    $rows[] = array(array('data' => t('No content types available. <a href="@link">Add content type</a>.', array('@link' => url('admin/structure/types/add'))), 'colspan' => '5', 'class' => array('message')));
  }
  
  $build['node_table'] = array(
    '#theme' => 'table',
    '#header' => $header,
    '#rows' => $rows
  );

  return $build;
}

function theme_node_admin_overview($name, $type) {
  $output = check_plain($name);
  $output .= ' <small> (Machine name: ' . check_plain($type->type) . ')</small>';
  $output .= '<div class="description">' . filter_xss_admin($type->description) . '</div>';
  return $output;
}

/**
 * Generates the node type editing form.
 */
function node_type_form($form, &$form_state, $type = NULL) {
  if (!isset($type->type)) {
    // This is a new type. Node module managed types are custom and unlocked.
    $type = node_type_set_defaults(array('custom' => 1, 'locked' => 0));
  }

  // Make the type object available to implementations of hook_form_alter.
  $form['#node_type'] = $type;

  $form['identity'] = array(
    '#type' => 'fieldset',
    '#title' => t('Identification'),
  );
  $form['identity']['name'] = array(
    '#title' => t('Name'),
    '#type' => 'textfield',
    '#default_value' => $type->name,
    '#description' => t('The human-readable name of this content type. This text will be displayed as part of the list on the <em>add new content</em> page. It is recommended that this name begin with a capital letter and contain only letters, numbers, and <strong>spaces</strong>. This name must be unique.'),
    '#required' => TRUE,
    '#size' => 30,
    '#field_suffix' => ' <small id="edit-name-suffix">' . ($type->locked ? t('Machine name: @name', array('@name' => $type->type)) : '&nbsp') . '</small>',
  );

  if (!$type->locked) {
    $js_settings = array(
      'type' => 'setting',
      'data' => array(
        'machineReadableValue' => array(
          'name' => array(
            'text' => t('Machine name'),
            'target' => 'type',
            'searchPattern' => '[^a-z0-9]+',
            'replaceToken' => '_',
          ),
        ),
      ),
    );
    $form['identity']['type'] = array(
      '#title' => t('Machine name'),
      '#type' => 'textfield',
      '#default_value' => $type->type,
      '#maxlength' => 32,
      '#required' => TRUE,
      '#description' => t('The machine-readable name of this content type. This text will be used for constructing the URL of the <em>add new content</em> page for this content type. This name must contain only lowercase letters, numbers, and underscores. Underscores will be converted into hyphens when constructing the URL of the <em>add new content</em> page. This name must be unique.'),
      '#attached' => array(
        'js' => array(drupal_get_path('module', 'system') . '/system.js', $js_settings),
      ),
    );
  }
  else {
    $form['identity']['type'] = array(
      '#type' => 'value',
      '#value' => $type->type,
    );
  }

  $form['identity']['description'] = array(
    '#title' => t('Description'),
    '#type' => 'textarea',
    '#default_value' => $type->description,
  );

  $form['additional_settings'] = array(
    '#type' => 'vertical_tabs',
  );

  $form['submission'] = array(
    '#type' => 'fieldset',
    '#title' => t('Submission form settings'),
    '#collapsible' => TRUE,
    '#group' => 'additional_settings',
  );
  $form['submission']['title_label'] = array(
    '#title' => t('Title field label'),
    '#type' => 'textfield',
    '#default_value' => $type->title_label,
    '#required' => TRUE,
  );
  if (!$type->has_title) {
    // Avoid overwriting a content type that intentionally does not have a
    // title field.
    $form['submission']['title_label']['#attributes'] = array('disabled' => 'disabled');
    $form['submission']['title_label']['#description'] = t('This content type does not have a title field.');
    $form['submission']['title_label']['#required'] = FALSE;
  }
  $form['submission']['body_label'] = array(
    '#title' => t('Body field label'),
    '#type' => 'textfield',
    '#default_value' => isset($type->body_label) ? $type->body_label : '',
    '#description' => t('To remove the body field, remove text and leave blank.'),
  );
  $form['submission']['node_preview'] = array(
    '#type' => 'radios',
    '#title' => t('Preview before submitting'),
    '#default_value' => variable_get('node_preview_' . $type->type, DRUPAL_OPTIONAL),
    '#options' => array(
      DRUPAL_DISABLED => t('Disabled'),
      DRUPAL_OPTIONAL => t('Optional'),
      DRUPAL_REQUIRED => t('Required'),
    ),
    );
  $form['submission']['help']  = array(
    '#type' => 'textarea',
    '#title' => t('Explanation or submission guidelines'),
    '#default_value' => $type->help,
    '#description' => t('This text will be displayed at the top of the submission form for this content type.')
  );
  $form['workflow'] = array(
    '#type' => 'fieldset',
    '#title' => t('Publishing options'),
    '#collapsible' => TRUE,
    '#collapsed' => TRUE,
    '#group' => 'additional_settings',
  );
  $form['workflow']['node_options'] = array('#type' => 'checkboxes',
    '#title' => t('Default options'),
    '#default_value' => variable_get('node_options_' . $type->type, array('status', 'promote')),
    '#options' => array(
      'status' => t('Published'),
      'promote' => t('Promoted to front page'),
      'sticky' => t('Sticky at top of lists'),
      'revision' => t('Create new revision'),
    ),
    '#description' => t('Users with the <em>administer nodes</em> permission will be able to override these options.'),
  );
  $form['display'] = array(
    '#type' => 'fieldset',
    '#title' => t('Display settings'),
    '#collapsible' => TRUE,
    '#collapsed' => TRUE,
    '#group' => 'additional_settings',
  );
  $form['display']['node_submitted'] = array(
    '#type' => 'checkbox',
    '#title' => t('Display post information'),
    '#default_value' => variable_get('node_submitted_' . $type->type, TRUE),
    '#description' => t('Enable the <em>submitted by Username on date</em> text.'),
  );
  $form['display']['teaser_length'] = array(
    '#type' => 'select', 
    '#title' => t('Length of trimmed posts'),
    '#default_value' => variable_get('teaser_length_' . $type->type, 600),
    '#options' => drupal_map_assoc(array(0, 200, 400, 600, 800, 1000, 1200, 1400, 1600, 1800, 2000), '_node_characters'),
    '#description' => t("The maximum number of characters used in the trimmed version of content.")
  );
  $form['old_type'] = array(
    '#type' => 'value',
    '#value' => $type->type,
  );
  $form['orig_type'] = array(
    '#type' => 'value',
    '#value' => isset($type->orig_type) ? $type->orig_type : '',
  );
  $form['base'] = array(
    '#type' => 'value',
    '#value' => $type->base,
  );
  $form['custom'] = array(
    '#type' => 'value',
    '#value' => $type->custom,
  );
  $form['modified'] = array(
    '#type' => 'value',
    '#value' => $type->modified,
  );
  $form['locked'] = array(
    '#type' => 'value',
    '#value' => $type->locked,
  );

  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => t('Save content type'),
    '#weight' => 40,
  );

  if ($type->custom) {
    if (!empty($type->type)) {
      $form['delete'] = array(
        '#type' => 'submit',
        '#value' => t('Delete content type'),
        '#weight' => 45,
      );
    }
  }

  return $form;
}

/**
 * Helper function for teaser length choices.
 */
function _node_characters($length) {
  return ($length == 0) ? t('Unlimited') : format_plural($length, '1 character', '@count characters');
}

/**
 * Validates the content type submission form generated by node_type_form().
 */
function node_type_form_validate($form, &$form_state) {
  $type = new stdClass();
  $type->type = trim($form_state['values']['type']);
  $type->name = trim($form_state['values']['name']);

  // Work out what the type was before the user submitted this form
  $old_type = trim($form_state['values']['old_type']);

  $types = node_type_get_names();

  if (!$form_state['values']['locked']) {
    if (isset($types[$type->type]) && $type->type != $old_type) {
      form_set_error('type', t('The machine-readable name %type is already taken.', array('%type' => $type->type)));
    }
    if (!preg_match('!^[a-z0-9_]+$!', $type->type)) {
      form_set_error('type', t('The machine-readable name must contain only lowercase letters, numbers, and underscores.'));
    }
    // 'theme' conflicts with theme_node_form().
    // '0' is invalid, since elsewhere we check it using empty().
    if (in_array($type->type, array('0', 'theme'))) {
      form_set_error('type', t("Invalid machine-readable name. Please enter a name other than %invalid.", array('%invalid' => $type->type)));
    }
  }

  $names = array_flip($types);

  if (isset($names[$type->name]) && $names[$type->name] != $old_type) {
    form_set_error('name', t('The human-readable name %name is already taken.', array('%name' => $type->name)));
  }
}

/**
 * Implement hook_form_submit().
 */
function node_type_form_submit($form, &$form_state) {
  $op = isset($form_state['values']['op']) ? $form_state['values']['op'] : '';

  $type = node_type_set_defaults();

  $type->type = trim($form_state['values']['type']);
  $type->name = trim($form_state['values']['name']);
  $type->orig_type = trim($form_state['values']['orig_type']);
  $type->old_type = isset($form_state['values']['old_type']) ? $form_state['values']['old_type'] : $type->type;

  $type->description = $form_state['values']['description'];
  $type->help = $form_state['values']['help'];
  $type->title_label = $form_state['values']['title_label'];
  $type->body_label = $form_state['values']['body_label'];

  // title_label is required in core; has_title will always be true, unless a
  // module alters the title field.
  $type->has_title = ($type->title_label != '');
  $type->has_body = ($type->body_label != '');

  $type->base = !empty($form_state['values']['base']) ? $form_state['values']['base'] : 'node_content';
  $type->custom = $form_state['values']['custom'];
  $type->modified = TRUE;
  $type->locked = $form_state['values']['locked'];

  if ($op == t('Delete content type')) {
    $form_state['redirect'] = 'admin/structure/node-type/' . str_replace('_', '-', $type->old_type) . '/delete';
    return;
  }

  $status = node_type_save($type);

  $variables = $form_state['values'];

  // Remove everything that's been saved already - whatever's left is assumed
  // to be a persistent variable.
  foreach ($variables as $key => $value) {
    if (isset($type->$key)) {
      unset($variables[$key]);
    }
  }

  unset($variables['form_token'], $variables['op'], $variables['submit'], $variables['delete'], $variables['reset'], $variables['form_id'], $variables['form_build_id']);

  // Save or reset persistent variable values.
  foreach ($variables as $key => $value) {
    $variable_new = $key . '_' . $type->type;
    $variable_old = $key . '_' . $type->old_type;

    if (is_array($value)) {
      $value = array_keys(array_filter($value));
    }
    variable_set($variable_new, $value);

    if ($variable_new != $variable_old) {
      variable_del($variable_old);
    }
  }

  node_types_rebuild();
  menu_rebuild();
  $t_args = array('%name' => $type->name);

  if ($status == SAVED_UPDATED) {
    drupal_set_message(t('The content type %name has been updated.', $t_args));
  }
  elseif ($status == SAVED_NEW) {
    drupal_set_message(t('The content type %name has been added.', $t_args));
    watchdog('node', 'Added content type %name.', $t_args, WATCHDOG_NOTICE, l(t('view'), 'admin/structure/types'));
  }

  $form_state['redirect'] = 'admin/structure/types';
  return;
}

/**
 * Implement hook_node_type_insert().
 */
function node_node_type_insert($info) {
  if (!empty($info->old_type) && $info->old_type != $info->type) {
    $update_count = node_type_update_nodes($info->old_type, $info->type);

    if ($update_count) {
      drupal_set_message(format_plural($update_count, 'Changed the content type of 1 post from %old-type to %type.', 'Changed the content type of @count posts from %old-type to %type.', array('%old-type' => $info->old_type, '%type' => $info->type)));
    }
  }
}

/**
 * Implement hook_node_type_update().
 */
function node_node_type_update($info) {
  if (!empty($info->old_type) && $info->old_type != $info->type) {
    $update_count = node_type_update_nodes($info->old_type, $info->type);

    if ($update_count) {
      drupal_set_message(format_plural($update_count, 'Changed the content type of 1 post from %old-type to %type.', 'Changed the content type of @count posts from %old-type to %type.', array('%old-type' => $info->old_type, '%type' => $info->type)));
    }
  }
}

/**
 * Resets all of the relevant fields of a module-defined node type to their
 * default values.
 *
 * @param $type
 *   The node type to reset. The node type is passed back by reference with its
 *   resetted values. If there is no module-defined info for this node type,
 *   then nothing happens.
 */
function node_type_reset($type) {
  $info_array = module_invoke_all('node_info');
  if (isset($info_array[$type->orig_type])) {
    $info_array[$type->orig_type]['type'] = $type->orig_type;
    $info = node_type_set_defaults($info_array[$type->orig_type]);

    foreach ($info as $field => $value) {
      $type->$field = $value;
    }
  }
}

/**
 * Menu callback; delete a single content type.
 */
function node_type_delete_confirm($form, &$form_state, $type) {
  $form['type'] = array('#type' => 'value', '#value' => $type->type);
  $form['name'] = array('#type' => 'value', '#value' => $type->name);

  $message = t('Are you sure you want to delete the content type %type?', array('%type' => $type->name));
  $caption = '';

  $num_nodes = db_query("SELECT COUNT(*) FROM {node} WHERE type = :type", array(':type' => $type->type))->fetchField();
  if ($num_nodes) {
    $caption .= '<p>' . format_plural($num_nodes, '<strong>Warning:</strong> there is currently 1 %type post on your site. It may not be able to be displayed or edited correctly once you have removed this content type.', '<strong>Warning:</strong> there are currently @count %type posts on your site. They may not be able to be displayed or edited correctly once you have removed this content type.', array('%type' => $type->name)) . '</p>';
  }

  $caption .= '<p>' . t('This action cannot be undone.') . '</p>';

  return confirm_form($form, $message, 'admin/structure/types', $caption, t('Delete'));
}

/**
 * Process content type delete confirm submissions.
 */
function node_type_delete_confirm_submit($form, &$form_state) {
  node_type_delete($form_state['values']['type']);

  variable_del('teaser_length_' . $form_state['values']['type']);
  variable_del('node_preview_' . $form_state['values']['type']);
  $t_args = array('%name' => $form_state['values']['name']);
  drupal_set_message(t('The content type %name has been deleted.', $t_args));
  watchdog('menu', 'Deleted content type %name.', $t_args, WATCHDOG_NOTICE);

  node_types_rebuild();
  menu_rebuild();

  $form_state['redirect'] = 'admin/structure/types';
  return;
}
