<?php
// $Id: trigger.admin.inc,v 1.18 2009/09/19 11:07:36 dries Exp $

/**
 * @file
 * Admin page callbacks for the trigger module.
 */

/**
 * Builds the form that allows users to assign actions to triggers.
 *
 * @param $module_to_display
 *   Which tab of triggers to display. E.g., 'node' for all
 *   node-related triggers.
 * @return
 *   HTML form.
 */
function trigger_assign($module_to_display = NULL) {
  // If no type is specified we default to node actions, since they
  // are the most common.
  if (!isset($module_to_display)) {
    drupal_goto('admin/structure/trigger/node');
  }

  $build = array();
  $trigger_info = module_invoke_all('trigger_info');
  drupal_alter('trigger_info', $trigger_info);
  foreach ($trigger_info as $module => $hooks) {
    if ($module == $module_to_display) {
      foreach ($hooks as $hook => $description) {
        $form_id = 'trigger_' . $hook . '_assign_form';
        $build[$form_id] = drupal_get_form($form_id, $module, $hook, $description['label']);
      }
    }
  }
  return $build;
}

/**
 * Confirm removal of an assigned action.
 *
 * @param $module
 *   The tab of triggers the user will be directed to after successful
 *   removal of the action, or if the confirmation form is cancelled.
 * @param $hook
 * @param $aid
 *   The action ID.
 * @ingroup forms
 * @see trigger_unassign_submit()
 */
function trigger_unassign($form, $form_state, $module, $hook = NULL, $aid = NULL) {
  if (!($hook && $aid)) {
    drupal_goto('admin/structure/trigger');
  }

  $form['hook'] = array(
    '#type' => 'value',
    '#value' => $hook,
  );
  $form['module'] = array(
    '#type' => 'value',
    '#value' => $module,
  );
  $form['aid'] = array(
    '#type' => 'value',
    '#value' => $aid,
  );

  $action = actions_function_lookup($aid);
  $actions = actions_get_all_actions();

  $destination = 'admin/structure/trigger/' . $module;

  return confirm_form($form,
    t('Are you sure you want to unassign the action %title?', array('%title' => $actions[$action]['label'])),
    $destination,
    t('You can assign it again later if you wish.'),
    t('Unassign'), t('Cancel')
  );
}

/**
 * Submit callback for trigger_unassign() form.
 */
function trigger_unassign_submit($form, &$form_state) {
  $form_values = $form_state['values'];
  if ($form_values['confirm'] == 1) {
    $aid = actions_function_lookup($form_values['aid']);
    db_delete('trigger_assignments')
      ->condition('hook', $form_values['hook'])
      ->condition('aid', $aid)
      ->execute();
    $actions = actions_get_all_actions();
    watchdog('actions', 'Action %action has been unassigned.',  array('%action' => check_plain($actions[$aid]['label'])));
    drupal_set_message(t('Action %action has been unassigned.', array('%action' => $actions[$aid]['label'])));
    $form_state['redirect'] = 'admin/structure/trigger/' . $form_values['module'];
  }
  else {
    drupal_goto('admin/structure/trigger');
  }
}

/**
 * Returns the form for assigning an action to a trigger.
 *
 * @param $module
 *   The name of the trigger group, e.g., 'node'.
 * @param $hook
 *   The name of the trigger hook, e.g., 'node_insert'.
 * @param $label
 *   A plain English description of what this trigger does.
 *
 * @ingoup forms
 * @see trigger_assign_form_validate()
 * @see trigger_assign_form_submit()
 */
function trigger_assign_form($form, $form_state, $module, $hook, $label) {
  $form['module'] = array(
    '#type' => 'hidden',
    '#value' => $module,
  );
  $form['hook'] = array(
    '#type' => 'hidden',
    '#value' => $hook,
  );
  // All of these forms use the same validate and submit functions.
  $form['#validate'][] = 'trigger_assign_form_validate';
  $form['#submit'][] = 'trigger_assign_form_submit';

  $options = array();
  $functions = array();
  // Restrict the options list to actions that declare support for this hook.
  foreach (actions_list() as $func => $metadata) {
    if (in_array('any', $metadata['triggers']) || in_array($hook, $metadata['triggers'])) {
      $functions[] = $func;
    }
  }
  foreach (actions_actions_map(actions_get_all_actions()) as $aid => $action) {
    if (in_array($action['callback'], $functions)) {
      $options[$action['type']][$aid] = $action['label'];
    }
  }

  $form[$hook] = array(
    '#type' => 'fieldset',
    '#title' => t('Trigger: ') . $label,
    '#theme' => 'trigger_display'
  );

  // Retrieve actions that are already assigned to this hook combination.
  $actions = trigger_get_assigned_actions($hook);
  $form[$hook]['assigned']['#type'] = 'value';
  $form[$hook]['assigned']['#value'] = array();
  foreach ($actions as $aid => $info) {
    $form[$hook]['assigned']['#value'][$aid] = array(
      'label' => $info['label'],
      'link' => l(t('unassign'), "admin/structure/trigger/unassign/$module/$hook/" . md5($aid)),
    );
  }

  $form[$hook]['parent'] = array(
    '#prefix' => "<div class='container-inline'>",
    '#suffix' => '</div>',
  );
  // List possible actions that may be assigned.
  if (count($options) != 0) {
    array_unshift($options, t('Choose an action'));
    $form[$hook]['parent']['aid'] = array(
      '#type' => 'select',
      '#options' => $options,
    );
    $form[$hook]['parent']['submit'] = array(
      '#type' => 'submit',
      '#value' => t('Assign')
    );
  }
  else {
    $form[$hook]['none'] = array(
      '#markup' => t('No actions available for this trigger. <a href="@link">Add action</a>.', array('@link' => url('admin/config/system/actions/manage')))
    );
  }
  return $form;
}

/**
 * Validation function for trigger_assign_form().
 *
 * Makes sure that the user is not re-assigning an action to an event.
 */
function trigger_assign_form_validate($form, $form_state) {
  $form_values = $form_state['values'];
  if (!empty($form_values['aid'])) {
    $aid = actions_function_lookup($form_values['aid']);
    $aid_exists = db_query("SELECT aid FROM {trigger_assignments} WHERE hook = :hook AND aid = :aid", array(
      ':hook' => $form_values['hook'],
      ':aid' => $aid,
    ))->fetchField();
    if ($aid_exists) {
      form_set_error($form_values['hook'], t('The action you chose is already assigned to that trigger.'));
    }
  }
}

/**
 * Submit function for trigger_assign_form().
 */
function trigger_assign_form_submit($form, $form_state) {
  $form_values = $form_state['values'];

  if (!empty($form_values['aid'])) {
    $aid = actions_function_lookup($form_values['aid']);
    $weight = db_query("SELECT MAX(weight) FROM {trigger_assignments} WHERE hook = :hook", array(
      ':hook' => $form_values['hook'],
    ))->fetchField();

    db_insert('trigger_assignments')
      ->fields(array(
        'hook' => $form_values['hook'],
        'aid' => $aid,
        'weight' => $weight + 1,
      ))
      ->execute();
    // If this action changes a node property, we need to save the node
    // so the change will persist.

    $actions = actions_list();
    if (isset($actions[$aid]['behavior']) && in_array('changes_node_property', $actions[$aid]['behavior']) && ($form_values['hook'] != 'node_presave') && ($form_values['hook'] != 'comment_presave')) {
      // Delete previous node_save_action if it exists, and re-add a new one at
      // a higher weight.
      $save_post_action_assigned = db_query("SELECT aid FROM {trigger_assignments} WHERE hook = :hook AND aid = :aid", array(
        ':hook' => $form_values['hook'],
        ':aid' => 'node_save_action',
      ))->fetchField();

      if ($save_post_action_assigned) {
        db_delete('trigger_assignments')
          ->condition('hook', $form_values['hook'])
          ->condition('aid', 'node_save_action')
          ->execute();
      }
      db_insert('trigger_assignments')
        ->fields(array(
          'hook' => $form_values['hook'],
          'aid' => 'node_save_action',
          'weight' => $weight + 2,
        ))
        ->execute();
      if (!$save_post_action_assigned) {
        drupal_set_message(t("You have added an action that changes a the property of some content. Your 'Save content' action has been moved later in the list so that the property change will be saved."));
      }
    }
  }
}

/**
 * Displays actions assigned to this hook in a table.
 *
 * @param array $element
 *   The fieldset including all assigned actions.
 * @return
 *   The rendered form with the table prepended.
 *
 * @ingroup themeable
 */
function theme_trigger_display($element) {
  $header = array();
  $rows = array();
  if (isset($element['assigned']) && count($element['assigned']['#value'])) {
    $header = array(array('data' => t('Name')), array('data' => t('Operation')));
    $rows = array();
    foreach ($element['assigned']['#value'] as $aid => $info) {
      $rows[] = array(
        $info['label'],
        $info['link']
      );
    }
  }

  if (count($rows)) {
    $output = theme('table', $header, $rows) . drupal_render_children($element);
  }
  else {
    $output = drupal_render_children($element);
  }
  return $output;
}

