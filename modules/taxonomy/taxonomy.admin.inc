<?php
// $Id: taxonomy.admin.inc,v 1.70 2009/09/21 06:44:14 dries Exp $

/**
 * @file
 * Administrative page callbacks for the taxonomy module.
 */

/**
 * Form builder to list and manage vocabularies.
 *
 * @ingroup forms
 * @see taxonomy_overview_vocabularies_submit()
 * @see theme_taxonomy_overview_vocabularies()
 */
function taxonomy_overview_vocabularies($form) {
  $vocabularies = taxonomy_get_vocabularies();
  $form['#tree'] = TRUE;
  foreach ($vocabularies as $vocabulary) {
    $types = array();
    foreach ($vocabulary->nodes as $type) {
      $node_type = node_type_get_name($type);
      $types[] = $node_type ? check_plain($node_type) : check_plain($type);
    }
    $form[$vocabulary->vid]['#vocabulary'] = $vocabulary;
    $form[$vocabulary->vid]['name'] = array('#markup' => check_plain($vocabulary->name));
    $form[$vocabulary->vid]['types'] = array('#markup' => implode(', ', $types));
    $form[$vocabulary->vid]['weight'] = array('#type' => 'weight', '#delta' => 10, '#default_value' => $vocabulary->weight);
    $form[$vocabulary->vid]['edit'] = array('#markup' => l(t('edit vocabulary'), "admin/structure/taxonomy/$vocabulary->vid"));
    $form[$vocabulary->vid]['list'] = array('#markup' => l(t('list terms'), "admin/structure/taxonomy/$vocabulary->vid/list"));
    $form[$vocabulary->vid]['add'] = array('#markup' => l(t('add terms'), "admin/structure/taxonomy/$vocabulary->vid/list/add"));
  }

  // Only make this form include a submit button and weight if more than one
  // vocabulary exists.
  if (count($vocabularies) > 1) {
    $form['submit'] = array('#type' => 'submit', '#value' => t('Save'));
  }
  elseif (isset($vocabulary)) {
    unset($form[$vocabulary->vid]['weight']);
  }
  return $form;
}

/**
 * Submit handler for vocabularies overview. Updates changed vocabulary weights.
 *
 * @see taxonomy_overview_vocabularies()
 */
function taxonomy_overview_vocabularies_submit($form, &$form_state) {
  foreach ($form_state['values'] as $vid => $vocabulary) {
    if (is_numeric($vid) && $form[$vid]['#vocabulary']->weight != $form_state['values'][$vid]['weight']) {
      $form[$vid]['#vocabulary']->weight = $form_state['values'][$vid]['weight'];
      taxonomy_vocabulary_save($form[$vid]['#vocabulary']);
    }
  }
}

/**
 * Theme the vocabulary overview as a sortable list of vocabularies.
 *
 * @ingroup themeable
 * @see taxonomy_overview_vocabularies()
 */
function theme_taxonomy_overview_vocabularies($form) {
  $rows = array();

  foreach (element_children($form) as $key) {
    if (isset($form[$key]['name'])) {
      $vocabulary = &$form[$key];

      $row = array();
      $row[] = drupal_render($vocabulary['name']);
      $row[] = drupal_render($vocabulary['types']);
      if (isset($vocabulary['weight'])) {
        $vocabulary['weight']['#attributes']['class'] = array('vocabulary-weight');
        $row[] = drupal_render($vocabulary['weight']);
      }
      $row[] = drupal_render($vocabulary['edit']);
      $row[] = drupal_render($vocabulary['list']);
      $row[] = drupal_render($vocabulary['add']);
      $rows[] = array('data' => $row, 'class' => array('draggable'));
    }
  }

  if (empty($rows)) {
    $rows[] = array(array('data' => t('No vocabularies available. <a href="@link">Add vocabulary</a>.', array('@link' => url('admin/structure/taxonomy/add'))), 'colspan' => '5'));
  }

  $header = array(t('Vocabulary name'), t('Content types'));
  if (isset($form['submit'])) {
    $header[] = t('Weight');
    drupal_add_tabledrag('taxonomy', 'order', 'sibling', 'vocabulary-weight');
  }
  $header[] = array('data' => t('Operations'), 'colspan' => '3');
  return theme('table', $header, $rows, array('id' => 'taxonomy')) . drupal_render_children($form);
}

/**
 * Display form for adding and editing vocabularies.
 *
 * @ingroup forms
 * @see taxonomy_form_vocabulary_submit()
 */
function taxonomy_form_vocabulary($form, &$form_state, $edit = array()) {
  if (!is_array($edit)) {
    $edit = (array)$edit;
  }
  $edit += array(
    'name' => '',
    'machine_name' => '',
    'description' => '',
    'help' => '',
    'nodes' => array(),
    'hierarchy' => 0,
    'tags' => 0,
    'multiple' => 0,
    'required' => 0,
    'weight' => 0,
  );
  $form['#vocabulary'] = (object) $edit;
  // Check whether we need a deletion confirmation form.
  if (isset($form_state['confirm_delete']) && isset($form_state['values']['vid'])) {
    return taxonomy_vocabulary_confirm_delete($form, $form_state, $form_state['values']['vid']);
  }
  $form['name'] = array(
    '#type' => 'textfield',
    '#title' => t('Name'),
    '#default_value' => $edit['name'],
    '#maxlength' => 255,
    '#required' => TRUE,
    '#field_suffix' => ' <small id="edit-name-suffix">&nbsp</small>',
  );
  $js_settings = array(
    'type' => 'setting',
    'data' => array(
      'machineReadableValue' => array(
        'name' => array(
          'text' => t('Machine name'),
          'target' => 'machine-name',
          'searchPattern' => '[^a-z0-9]+',
          'replaceToken' => '_',
        ),
      ),
    ),
  );
  $form['machine_name'] = array(
    '#type' => 'textfield',
    '#title' => t('Machine readable name'),
    '#default_value' => $edit['machine_name'],
    '#maxlength' => 255,
    '#description' => t('The unique machine readable name for this vocabulary, used for theme templates, can only contain lowercase letters, numbers and underscores.'),
    '#required' => TRUE,
    '#attached' => array(
      'js' => array(drupal_get_path('module', 'system') . '/system.js', $js_settings),
    ),
  );
  $form['help'] = array(
    '#type' => 'textfield',
    '#title' => t('Help text'),
    '#maxlength' => 255,
    '#default_value' => $edit['help'],
    '#description' => t('Instructions to present to the user when selecting terms, e.g., <em>"Enter a comma separated list of words"</em>.'),
  );
  $form['description'] = array(
    '#type' => 'textfield',
    '#title' => t('Description'),
    '#default_value' => $edit['description'],
  );
  $form['nodes'] = array(
    '#type' => 'checkboxes',
    '#title' => t('Apply to content types'),
    '#default_value' => $edit['nodes'],
    '#options' => array_map('check_plain', node_type_get_names()),
  );
  $form['settings'] = array(
    '#type' => 'fieldset',
    '#title' => t('Settings'),
    '#collapsible' => TRUE,
  );
  $form['settings']['tags'] = array(
    '#type' => 'checkbox',
    '#title' => t('Tags'),
    '#default_value' => $edit['tags'],
    '#description' => t('Terms are created by users when submitting posts by typing a comma separated list.'),
  );
  $form['settings']['multiple'] = array(
    '#type' => 'checkbox',
    '#title' => t('Multiple select'),
    '#default_value' => $edit['multiple'],
    '#description' => t('Allows posts to have more than one term from this vocabulary (always true for tags).'),
  );
  $form['settings']['required'] = array(
    '#type' => 'checkbox',
    '#title' => t('Required'),
    '#default_value' => $edit['required'],
    '#description' => t('At least one term in this vocabulary must be selected when submitting a post.'),
  );
  // Set the hierarchy to "multiple parents" by default. This simplifies the
  // vocabulary form and standardizes the term form.
  $form['hierarchy'] = array(
    '#type' => 'value',
    '#value' => '0',
  );

  $form['submit'] = array('#type' => 'submit', '#value' => t('Save'));
  if (isset($edit['vid'])) {
    $form['delete'] = array('#type' => 'submit', '#value' => t('Delete'));
    $form['vid'] = array('#type' => 'value', '#value' => $edit['vid']);
    $form['module'] = array('#type' => 'value', '#value' => $edit['module']);
  }
  return $form;
}

/**
 * Validation handler for the vocabulary form.
 *
 * @see taxonomy_form_vocabulary()
 */
function taxonomy_form_vocabulary_validate($form, &$form_state) {
  if ($form_state['clicked_button']['#value'] != t('Delete') && isset($form_state['values']['machine_name'])) {

    // Restrict machine names to appropriate characters.
    $machine_name = $form_state['values']['machine_name'];
    if (!preg_match('!^[a-z0-9_]+$!', $form_state['values']['machine_name'])) {
      form_set_error('machine_name', t('The machine-readable name must contain only lowercase letters, numbers, and underscores.'));
    }

    // Do not allow duplicate machine names.
    $vocabularies = taxonomy_get_vocabularies();
    foreach ($vocabularies as $vocabulary) {
      if ($machine_name == $vocabulary->machine_name && (!isset($form_state['values']['vid']) || $vocabulary->vid != $form_state['values']['vid'])) {
        form_set_error('machine_name', t('This machine-readable name is already in use by another vocabulary and must be unique.'));
      }
    }
  }
}
/**
 * Accept the form submission for a vocabulary and save the results.
 */
function taxonomy_form_vocabulary_submit($form, &$form_state) {
  $old_vocabulary = $form['#vocabulary'];
  if ($form_state['clicked_button']['#value'] == t('Delete')) {
    // Rebuild the form to confirm vocabulary deletion.
    $form_state['rebuild'] = TRUE;
    $form_state['confirm_delete'] = TRUE;
    return;
  }
  // Fix up the nodes array to remove unchecked nodes.
  $form_state['values']['nodes'] = array_filter($form_state['values']['nodes']);
  $vocabulary = (object) $form_state['values'];
  if ($vocabulary->machine_name != $old_vocabulary->machine_name) {
    field_attach_rename_bundle($old_vocabulary->machine_name, $vocabulary->machine_name);
  }
  switch (taxonomy_vocabulary_save($vocabulary)) {
    case SAVED_NEW:
      drupal_set_message(t('Created new vocabulary %name.', array('%name' => $vocabulary->name)));
      watchdog('taxonomy', 'Created new vocabulary %name.', array('%name' => $vocabulary->name), WATCHDOG_NOTICE, l(t('edit'), 'admin/structure/taxonomy/' . $vocabulary->vid));
      break;
    case SAVED_UPDATED:
      drupal_set_message(t('Updated vocabulary %name.', array('%name' => $vocabulary->name)));
      watchdog('taxonomy', 'Updated vocabulary %name.', array('%name' => $vocabulary->name), WATCHDOG_NOTICE, l(t('edit'), 'admin/structure/taxonomy/' . $vocabulary->vid));
      break;
  }

  $form_state['vid'] = $vocabulary->vid;
  $form_state['redirect'] = 'admin/structure/taxonomy';
  return;
}

/**
 * Form builder for the taxonomy terms overview.
 *
 * Display a tree of all the terms in a vocabulary, with options to edit
 * each one. The form is made drag and drop by the theme function.
 *
 * @ingroup forms
 * @see taxonomy_overview_terms_submit()
 * @see theme_taxonomy_overview_terms()
 */
function taxonomy_overview_terms($form, &$form_state, $vocabulary) {
  global $pager_page_array, $pager_total, $pager_total_items;

  // Check for confirmation forms.
  if (isset($form_state['confirm_reset_alphabetical'])) {
    return taxonomy_vocabulary_confirm_reset_alphabetical($form_state, $vocabulary->vid);
  }

  $form['#vocabulary'] = $vocabulary;
  $form['#tree'] = TRUE;
  $form['#parent_fields'] = FALSE;

  $page            = isset($_GET['page']) ? $_GET['page'] : 0;
  $page_increment  = variable_get('taxonomy_terms_per_page_admin', 100);  // Number of terms per page.
  $page_entries    = 0;   // Elements shown on this page.
  $before_entries  = 0;   // Elements at the root level before this page.
  $after_entries   = 0;   // Elements at the root level after this page.
  $root_entries    = 0;   // Elements at the root level on this page.

  // Terms from previous and next pages are shown if the term tree would have
  // been cut in the middle. Keep track of how many extra terms we show on each
  // page of terms.
  $back_peddle    = NULL;
  $forward_peddle = 0;

  // An array of the terms to be displayed on this page.
  $current_page = array();

  // Case for free tagging.
  if ($vocabulary->tags) {
    // We are not calling taxonomy_get_tree because that might fail with a big
    // number of tags in the freetagging vocabulary.
    $query = db_select('taxonomy_term_data', 't')->extend('PagerDefault');
    $query->join('taxonomy_term_hierarchy', 'h', 't.tid = h.tid');
    $query->addTag('term_access');
    $query->condition('t.vid', $vocabulary->vid);

    // Store count in total entries and use this as count query.
    $count_query = db_select('taxonomy_term_data', 't');
    $count_query->join('taxonomy_term_hierarchy', 'h', 't.tid = h.tid');
    $count_query->addTag('term_access');
    $count_query->condition('t.vid', $vocabulary->vid);
    $count_query->addExpression('COUNT(t.tid)');
    $total_entries = $count_query->execute();
    $query->setCountQuery($count_query);

    $result = $query
      ->fields('t')
      ->fields('h', array('parent'))
      ->orderBy('weight')
      ->orderBy('name')
      ->limit($page_increment)
      ->execute();

    foreach ($result as $term) {
      $key = 'tid:' . $term->tid . ':0';
      $current_page[$key] = $term;
      $page_entries++;
    }
  }
  // Case for restricted vocabulary.
  else {
    $term_deltas = array();
    $tree = taxonomy_get_tree($vocabulary->vid);
    $term = current($tree);
    do {
      // In case this tree is completely empty.
      if (empty($term)) {
        break;
      }
      // Count entries before the current page.
      if ($page && ($page * $page_increment) > $before_entries && !isset($back_peddle)) {
        $before_entries++;
        continue;
      }
      // Count entries after the current page.
      elseif ($page_entries > $page_increment && isset($complete_tree)) {
        $after_entries++;
        continue;
      }

      // Do not let a term start the page that is not at the root.
      if (isset($term->depth) && ($term->depth > 0) && !isset($back_peddle)) {
        $back_peddle = 0;
        while ($pterm = prev($tree)) {
          $before_entries--;
          $back_peddle++;
          if ($pterm->depth == 0) {
            prev($tree);
            continue 2; // Jump back to the start of the root level parent.
          }
        }
      }
      $back_peddle = isset($back_peddle) ? $back_peddle : 0;

      // Continue rendering the tree until we reach the a new root item.
      if ($page_entries >= $page_increment + $back_peddle + 1 && $term->depth == 0 && $root_entries > 1) {
        $complete_tree = TRUE;
        // This new item at the root level is the first item on the next page.
        $after_entries++;
        continue;
      }
      if ($page_entries >= $page_increment + $back_peddle) {
        $forward_peddle++;
      }

      // Finally, if we've gotten down this far, we're rendering a term on this page.
      $page_entries++;
      $term_deltas[$term->tid] = isset($term_deltas[$term->tid]) ? $term_deltas[$term->tid] + 1 : 0;
      $key = 'tid:' . $term->tid . ':' . $term_deltas[$term->tid];

      // Keep track of the first term displayed on this page.
      if ($page_entries == 1) {
        $form['#first_tid'] = $term->tid;
      }
      // Keep a variable to make sure at least 2 root elements are displayed.
      if ($term->parents[0] == 0) {
        $root_entries++;
      }
      $current_page[$key] = $term;
    } while ($term = next($tree));

    // Because we didn't use a pager query, set the necessary pager variables.
    $total_entries = $before_entries + $page_entries + $after_entries;
    $pager_total_items[0] = $total_entries;
    $pager_page_array[0] = $page;
    $pager_total[0] = ceil($total_entries / $page_increment);
  }

  // If this form was already submitted once, it's probably hit a validation
  // error. Ensure the form is rebuilt in the same order as the user submitted.
  if (!empty($form_state['input'])) {
    $order = array_flip(array_keys($form_state['input'])); // Get the $_POST order.
    $current_page = array_merge($order, $current_page); // Update our form with the new order.
    foreach ($current_page as $key => $term) {
      // Verify this is a term for the current page and set at the current depth.
      if (is_array($form_state['input'][$key]) && is_numeric($form_state['input'][$key]['tid'])) {
        $current_page[$key]->depth = $form_state['input'][$key]['depth'];
      }
      else {
        unset($current_page[$key]);
      }
    }
  }

  // Build the actual form.
  foreach ($current_page as $key => $term) {
    // Save the term for the current page so we don't have to load it a second time.
    $form[$key]['#term'] = (array)$term;
    if (isset($term->parents)) {
      $form[$key]['#term']['parent'] = $term->parent = $term->parents[0];
      unset($form[$key]['#term']['parents'], $term->parents);
    }

    $form[$key]['view'] = array('#markup' => l($term->name, "taxonomy/term/$term->tid"));
    if (!$vocabulary->tags && $vocabulary->hierarchy < 2 && count($tree) > 1) {
      $form['#parent_fields'] = TRUE;
      $form[$key]['tid'] = array(
        '#type' => 'hidden',
        '#value' => $term->tid
      );
      $form[$key]['parent'] = array(
        '#type' => 'hidden',
        // Yes, default_value on a hidden. It needs to be changeable by the javascript.
        '#default_value' => $term->parent,
      );
      $form[$key]['depth'] = array(
        '#type' => 'hidden',
        // Same as above, the depth is modified by javascript, so it's a default_value.
        '#default_value' => $term->depth,
      );
    }
    $form[$key]['edit'] = array('#markup' => l(t('edit'), 'taxonomy/term/' . $term->tid . '/edit', array('query' => drupal_get_destination())));
  }

  $form['#total_entries'] = $total_entries;
  $form['#page_increment'] = $page_increment;
  $form['#page_entries'] = $page_entries;
  $form['#back_peddle'] = $back_peddle;
  $form['#forward_peddle'] = $forward_peddle;
  $form['#empty_text'] = t('No terms available. <a href="@link">Add term</a>.', array('@link' => url('admin/structure/taxonomy/' . $vocabulary->vid . '/list/add')));

  if (!$vocabulary->tags && $vocabulary->hierarchy < 2 && count($tree) > 1) {
    $form['submit'] = array(
      '#type' => 'submit',
      '#value' => t('Save')
    );
    $form['reset_alphabetical'] = array(
      '#type' => 'submit',
      '#value' => t('Reset to alphabetical')
    );
    $form_state['redirect'] = array($_GET['q'], (isset($_GET['page']) ? array('page' => $_GET['page']) : ''));
  }

  return $form;
}

/**
 * Submit handler for terms overview form.
 *
 * Rather than using a textfield or weight field, this form depends entirely
 * upon the order of form elements on the page to determine new weights.
 *
 * Because there might be hundreds or thousands of taxonomy terms that need to
 * be ordered, terms are weighted from 0 to the number of terms in the
 * vocabulary, rather than the standard -10 to 10 scale. Numbers are sorted
 * lowest to highest, but are not necessarily sequential. Numbers may be skipped
 * when a term has children so that reordering is minimal when a child is
 * added or removed from a term.
 *
 * @see taxonomy_overview_terms()
 */
function taxonomy_overview_terms_submit($form, &$form_state) {
  if ($form_state['clicked_button']['#value'] == t('Reset to alphabetical')) {
    // Execute the reset action.
    if ($form_state['values']['reset_alphabetical'] === TRUE) {
      return taxonomy_vocabulary_confirm_reset_alphabetical_submit($form, $form_state);
    }
    // Rebuild the form to confirm the reset action.
    $form_state['rebuild'] = TRUE;
    $form_state['confirm_reset_alphabetical'] = TRUE;
    return;
  }

  $order = array_flip(array_keys($form_state['input'])); // Get the $_POST order.
  $form_state['values'] = array_merge($order, $form_state['values']); // Update our original form with the new order.

  $vocabulary = $form['#vocabulary'];
  $hierarchy = 0; // Update the current hierarchy type as we go.

  $changed_terms = array();
  $tree = taxonomy_get_tree($vocabulary->vid);

  if (empty($tree)) {
    return;
  }

  // Build a list of all terms that need to be updated on previous pages.
  $weight = 0;
  $term = (array)$tree[0];
  while ($term['tid'] != $form['#first_tid']) {
    if ($term['parents'][0] == 0 && $term['weight'] != $weight) {
      $term['parent'] = $term['parents'][0];
      $term['weight'] = $weight;
      $changed_terms[$term['tid']] = $term;
    }
    $weight++;
    $hierarchy = $term['parents'][0] != 0 ? 1 : $hierarchy;
    $term = (array)$tree[$weight];
  }

  // Renumber the current page weights and assign any new parents.
  $level_weights = array();
  foreach ($form_state['values'] as $tid => $values) {
    if (isset($form[$tid]['#term'])) {
      $term = $form[$tid]['#term'];
      // Give terms at the root level a weight in sequence with terms on previous pages.
      if ($values['parent'] == 0 && $term['weight'] != $weight) {
        $term['weight'] = $weight;
        $changed_terms[$term['tid']] = $term;
      }
      // Terms not at the root level can safely start from 0 because they're all on this page.
      elseif ($values['parent'] > 0) {
        $level_weights[$values['parent']] = isset($level_weights[$values['parent']]) ? $level_weights[$values['parent']] + 1 : 0;
        if ($level_weights[$values['parent']] != $term['weight']) {
          $term['weight'] = $level_weights[$values['parent']];
          $changed_terms[$term['tid']] = $term;
        }
      }
      // Update any changed parents.
      if ($values['parent'] != $term['parent']) {
        $term['parent'] = $values['parent'];
        $changed_terms[$term['tid']] = $term;
      }
      $hierarchy = $term['parent'] != 0 ? 1 : $hierarchy;
      $weight++;
    }
  }

  // Build a list of all terms that need to be updated on following pages.
  for ($weight; $weight < count($tree); $weight++) {
    $term = (array)$tree[$weight];
    if ($term['parents'][0] == 0 && $term['weight'] != $weight) {
      $term['parent'] = $term['parents'][0];
      $term['weight'] = $weight;
      $changed_terms[$term['tid']] = $term;
    }
    $hierarchy = $term['parents'][0] != 0 ? 1 : $hierarchy;
  }

  // Save all updated terms.
  foreach ($changed_terms as $changed) {
    $term = (object)$changed;
    taxonomy_term_save($term);
  }

  // Update the vocabulary hierarchy to flat or single hierarchy.
  if ($vocabulary->hierarchy != $hierarchy) {
    $vocabulary->hierarchy = $hierarchy;
    taxonomy_vocabulary_save($vocabulary);
  }
}

/**
 * Theme the terms overview as a sortable list of terms.
 *
 * @ingroup themeable
 * @see taxonomy_overview_terms()
 */
function theme_taxonomy_overview_terms($form) {
  $page_increment  = $form['#page_increment'];
  $page_entries    = $form['#page_entries'];
  $back_peddle     = $form['#back_peddle'];
  $forward_peddle  = $form['#forward_peddle'];

  // Add drag and drop if parent fields are present in the form.
  if ($form['#parent_fields']) {
    drupal_add_tabledrag('taxonomy', 'match', 'parent', 'term-parent', 'term-parent', 'term-id', FALSE);
    drupal_add_tabledrag('taxonomy', 'depth', 'group', 'term-depth', NULL, NULL, FALSE);
    drupal_add_js(drupal_get_path('module', 'taxonomy') . '/taxonomy.js');
    drupal_add_js(array('taxonomy' => array('backPeddle' => $back_peddle, 'forwardPeddle' => $forward_peddle)), 'setting');
    drupal_add_css(drupal_get_path('module', 'taxonomy') . '/taxonomy.css');
  }

  $errors = form_get_errors() != FALSE ? form_get_errors() : array();
  $rows = array();
  foreach (element_children($form) as $key) {
    if (isset($form[$key]['#term'])) {
      $term = &$form[$key];

      $row = array();
      $row[] = (isset($term['#term']['depth']) && $term['#term']['depth'] > 0 ? theme('indentation', $term['#term']['depth']) : '') . drupal_render($term['view']);
      if ($form['#parent_fields']) {
        $term['tid']['#attributes']['class'] = array('term-id');
        $term['parent']['#attributes']['class'] = array('term-parent');
        $term['depth']['#attributes']['class'] = array('term-depth');
        $row[0] .= drupal_render($term['parent']) . drupal_render($term['tid']) . drupal_render($term['depth']);
      }
      $row[] = drupal_render($term['edit']);

      $row = array('data' => $row);
      $rows[$key] = $row;
    }
  }

  // Add necessary classes to rows.
  $row_position = 0;
  foreach ($rows as $key => $row) {
    $rows[$key]['class'] = array();
    if (isset($form['#parent_fields'])) {
      $rows[$key]['class'][] = 'draggable';
    }

    // Add classes that mark which terms belong to previous and next pages.
    if ($row_position < $back_peddle || $row_position >= $page_entries - $forward_peddle) {
      $rows[$key]['class'][] = 'taxonomy-term-preview';
    }

    if ($row_position !== 0 && $row_position !== count($rows) - 1) {
      if ($row_position == $back_peddle - 1 || $row_position == $page_entries - $forward_peddle - 1) {
        $rows[$key]['class'][] = 'taxonomy-term-divider-top';
      }
      elseif ($row_position == $back_peddle || $row_position == $page_entries - $forward_peddle) {
        $rows[$key]['class'][] = 'taxonomy-term-divider-bottom';
      }
    }

    // Add an error class if this row contains a form error.
    foreach ($errors as $error_key => $error) {
      if (strpos($error_key, $key) === 0) {
        $rows[$key]['class'][] = 'error';
      }
    }
    $row_position++;
  }

  if (empty($rows)) {
    $rows[] = array(array('data' => $form['#empty_text'], 'colspan' => '2'));
  }

  $header = array(t('Name'), t('Operations'));
  $output = theme('table', $header, $rows, array('id' => 'taxonomy'));
  $output .= drupal_render_children($form);
  $output .= theme('pager', NULL);

  return $output;
}

/**
 * Form function for the term edit form.
 *
 * @ingroup forms
 * @see taxonomy_form_term_submit()
 */
function taxonomy_form_term($form, &$form_state, $vocabulary, $edit = array()) {
  $edit += array(
    'name' => '',
    'description' => '',
    'vocabulary_machine_name' => $vocabulary->machine_name,
    'tid' => NULL,
    'weight' => 0,
  );

  // Take into account multi-step rebuilding.
  if (isset($form_state['term'])) {
    $edit = $form_state['term'] + $edit;
  }

  $parent = array_keys(taxonomy_get_parents($edit['tid']));
  $form['#term'] = $edit;
  $form['#term']['parent'] = $parent;
  $form['#vocabulary'] = $vocabulary;
  $form['#vocabulary']->nodes = drupal_map_assoc($vocabulary->nodes);
  $form['#builder_function'] = 'taxonomy_form_term_submit_builder';

  // Check for confirmation forms.
  if (isset($form_state['confirm_delete'])) {
    return array_merge($form, taxonomy_term_confirm_delete($form, $form_state, $edit['tid']));
  }
  elseif (isset($form_state['confirm_parents'])) {
    return array_merge($form, taxonomy_term_confirm_parents($form, $form_state, $vocabulary));
  }

  $form['identification'] = array(
    '#type' => 'fieldset',
    '#title' => t('Identification'),
    '#collapsible' => TRUE,
  );
  $form['identification']['name'] = array(
    '#type' => 'textfield',
    '#title' => t('Term name'),
    '#default_value' => $edit['name'],
    '#maxlength' => 255,
    '#required' => TRUE);
  $form['identification']['description'] = array(
    '#type' => 'textarea',
    '#title' => t('Description'),
    '#default_value' => $edit['description'],
    '#description' => t('A description of the term. To be displayed on taxonomy/term pages and RSS feeds.'));

  $form['vocabulary_machine_name'] = array(
    '#type' => 'textfield',
    '#access' => FALSE,
    '#value' => isset($edit['vocabulary_machine_name']) ? $edit['vocabulary_machine_name'] : $vocabulary->name,
  );

  field_attach_form('taxonomy_term', (object) $edit, $form, $form_state);

  $form['advanced'] = array(
    '#type' => 'fieldset',
    '#title' => t('Advanced options'),
    '#collapsible' => TRUE,
    '#collapsed' => $vocabulary->hierarchy < 2,
  );

  // taxonomy_get_tree and taxonomy_get_parents may contain large numbers of
  // items so we check for taxonomy_override_selector before loading the
  // full vocabulary. Contrib modules can then intercept before
  // hook_form_alter to provide scalable alternatives.
  if (!variable_get('taxonomy_override_selector', FALSE)) {
    $parent = array_keys(taxonomy_get_parents($edit['tid']));
    $children = taxonomy_get_tree($vocabulary->vid, $edit['tid']);

    // A term can't be the child of itself, nor of its children.
    foreach ($children as $child) {
      $exclude[] = $child->tid;
    }
    $exclude[] = $edit['tid'];

    $form['advanced']['parent'] = _taxonomy_term_select(t('Parents'), $parent, $vocabulary->vid, t('Parent terms') . '.', 1, '<' . t('root') . '>', $exclude);
  }
  $form['advanced']['synonyms'] = array(
    '#type' => 'textarea',
    '#title' => t('Synonyms'),
    '#default_value' => implode("\n", taxonomy_get_synonyms($edit['tid'])),
    '#description' => t('One synonym per line. Text input term selection widgets will show terms whose synonyms match the entered value as suggestions.'));
  $form['advanced']['weight'] = array(
    '#type' => 'textfield',
    '#title' => t('Weight'),
    '#size' => 6,
    '#default_value' => $edit['weight'],
    '#description' => t('Terms are displayed in ascending order by weight.'),
    '#required' => TRUE);
  $form['vid'] = array(
    '#type' => 'value',
    '#value' => $vocabulary->vid);
  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => t('Save'));

  if ($edit['tid']) {
    $form['delete'] = array(
      '#type' => 'submit',
      '#value' => t('Delete'));
    $form['tid'] = array(
      '#type' => 'value',
      '#value' => $edit['tid']);
  }
  else {
    $form_state['redirect'] = $_GET['q'];
  }

  return $form;
}

/**
 * Validation handler for the term form.
 *
 * @see taxonomy_form_term()
 */
function taxonomy_form_term_validate($form, &$form_state) {
  field_attach_form_validate('taxonomy_term', (object) $form_state['values'], $form, $form_state);

  // Ensure numeric values.
  if (isset($form_state['values']['weight']) && !is_numeric($form_state['values']['weight'])) {
    form_set_error('weight', t('Weight value must be numeric.'));
  }
}

/**
 * Submit handler to insert or update a term.
 *
 * @see taxonomy_form_term()
 */
function taxonomy_form_term_submit($form, &$form_state) {
  if ($form_state['clicked_button']['#value'] == t('Delete')) {
    // Execute the term deletion.
    if ($form_state['values']['delete'] === TRUE) {
      return taxonomy_term_confirm_delete_submit($form, $form_state);
    }
    // Rebuild the form to confirm term deletion.
    $form_state['rebuild'] = TRUE;
    $form_state['confirm_delete'] = TRUE;
    return;
  }
  // Rebuild the form to confirm enabling multiple parents.
  elseif ($form_state['clicked_button']['#value'] == t('Save') && !$form['#vocabulary']->tags && count($form_state['values']['parent']) > 1 && $form['#vocabulary']->hierarchy < 2) {
    $form_state['rebuild'] = TRUE;
    $form_state['confirm_parents'] = TRUE;
    return;
  }

  $term = taxonomy_form_term_submit_builder($form, $form_state);

  $status = taxonomy_term_save($term);
  switch ($status) {
    case SAVED_NEW:
      drupal_set_message(t('Created new term %term.', array('%term' => $term->name)));
      watchdog('taxonomy', 'Created new term %term.', array('%term' => $term->name), WATCHDOG_NOTICE, l(t('edit'), 'taxonomy/term/' . $term->tid . '/edit'));
      break;
    case SAVED_UPDATED:
      drupal_set_message(t('Updated term %term.', array('%term' => $term->name)));
      watchdog('taxonomy', 'Updated term %term.', array('%term' => $term->name), WATCHDOG_NOTICE, l(t('edit'), 'taxonomy/term/' . $term->tid . '/edit'));
      break;
  }

  if (!$form['#vocabulary']->tags) {
    $current_parent_count = count($form_state['values']['parent']);
    $previous_parent_count = count($form['#term']['parent']);
    // Root doesn't count if it's the only parent.
    if ($current_parent_count == 1 && isset($form_state['values']['parent'][0])) {
      $current_parent_count = 0;
      $form_state['values']['parent'] = array();
    }

    // If the number of parents has been reduced to one or none, do a check on the
    // parents of every term in the vocabulary value.
    if ($current_parent_count < $previous_parent_count && $current_parent_count < 2) {
      taxonomy_check_vocabulary_hierarchy($form['#vocabulary'], $form_state['values']);
    }
    // If we've increased the number of parents and this is a single or flat
    // hierarchy, update the vocabulary immediately.
    elseif ($current_parent_count > $previous_parent_count && $form['#vocabulary']->hierarchy < 2) {
      $form['#vocabulary']->hierarchy = $current_parent_count == 1 ? 1 : 2;
      taxonomy_vocabulary_save($form['#vocabulary']);
    }
  }

  $form_state['tid'] = $term->tid;
  $form_state['redirect'] = 'admin/structure/taxonomy';
  return;
}

/**
 * Build a term by processing form values and prepare for a form rebuild.
 */
function taxonomy_form_term_submit_builder($form, &$form_state) {
  $term = (object) $form_state['values'];
  field_attach_submit('taxonomy_term', $term, $form, $form_state);

  $form_state['term'] = (array)$term;
  $form_state['rebuild'] = TRUE;

  return $term;
}

/**
 * Form builder for the confirmation of multiple term parents.
 *
 * @ingroup forms
 * @see taxonomy_form_term()
 */
function taxonomy_term_confirm_parents($form, &$form_state, $vocabulary) {
  foreach (element_children($form_state['values']) as $key) {
    $form[$key] = array(
      '#type' => 'value',
      '#value' => $form_state['values'][$key],
    );
  }
  $question = t('Set multiple term parents?');
  $description = '<p>' . t("Adding multiple parents to a term will cause the %vocabulary vocabulary to look for multiple parents on every term. Because multiple parents are not supported when using the drag and drop outline interface, drag and drop will be disabled if you enable this option. If you choose to have multiple parents, you will only be able to set parents by using the term edit form.", array('%vocabulary' => $vocabulary->name)) . '</p>';
  $description .= '<p>' . t("You may re-enable the drag and drop interface at any time by reducing multiple parents to a single parent for the terms in this vocabulary.") . '</p>';
  return confirm_form($form, $question, drupal_get_destination(), $description, t('Set multiple parents'));
}

/**
 * Form builder for the term delete form.
 *
 * @ingroup forms
 * @see taxonomy_term_confirm_delete_submit()
 */
function taxonomy_term_confirm_delete($form, &$form_state, $tid) {
  $term = taxonomy_term_load($tid);

  $form['type'] = array('#type' => 'value', '#value' => 'term');
  $form['name'] = array('#type' => 'value', '#value' => $term->name);
  $form['tid'] = array('#type' => 'value', '#value' => $tid);
  $form['vocabulary_machine_name'] = array('#type' => 'value', '#value' => $term->vocabulary_machine_name);
  $form['delete'] = array('#type' => 'value', '#value' => TRUE);
  return confirm_form($form,
                  t('Are you sure you want to delete the term %title?',
                  array('%title' => $term->name)),
                  'admin/structure/taxonomy',
                  t('Deleting a term will delete all its children if there are any. This action cannot be undone.'),
                  t('Delete'),
                  t('Cancel'));
}

/**
 * Submit handler to delete a term after confirmation.
 *
 * @see taxonomy_term_confirm_delete()
 */
function taxonomy_term_confirm_delete_submit($form, &$form_state) {
  taxonomy_term_delete($form_state['values']['tid']);
  taxonomy_check_vocabulary_hierarchy($form['#vocabulary'], $form_state['values']);
  drupal_set_message(t('Deleted term %name.', array('%name' => $form_state['values']['name'])));
  watchdog('taxonomy', 'Deleted term %name.', array('%name' => $form_state['values']['name']), WATCHDOG_NOTICE);
  $form_state['redirect'] = 'admin/structure/taxonomy';
  return;
}

/**
 * Form builder for the vocabulary delete confirmation form.
 *
 * @ingroup forms
 * @see taxonomy_vocabulary_confirm_delete_submit()
 */
function taxonomy_vocabulary_confirm_delete($form, &$form_state, $vid) {
  $vocabulary = taxonomy_vocabulary_load($vid);

  $form['#id'] = 'taxonomy_vocabulary_confirm_delete';
  $form['type'] = array('#type' => 'value', '#value' => 'vocabulary');
  $form['vid'] = array('#type' => 'value', '#value' => $vid);
  $form['name'] = array('#type' => 'value', '#value' => $vocabulary->name);
  $form['#submit'] = array('taxonomy_vocabulary_confirm_delete_submit');
  return confirm_form($form,
                  t('Are you sure you want to delete the vocabulary %title?',
                  array('%title' => $vocabulary->name)),
                  'admin/structure/taxonomy',
                  t('Deleting a vocabulary will delete all the terms in it. This action cannot be undone.'),
                  t('Delete'),
                  t('Cancel'));
}

/**
 * Submit handler to delete a vocabulary after confirmation.
 *
 * @see taxonomy_vocabulary_confirm_delete()
 */
function taxonomy_vocabulary_confirm_delete_submit($form, &$form_state) {
  $status = taxonomy_vocabulary_delete($form_state['values']['vid']);
  drupal_set_message(t('Deleted vocabulary %name.', array('%name' => $form_state['values']['name'])));
  watchdog('taxonomy', 'Deleted vocabulary %name.', array('%name' => $form_state['values']['name']), WATCHDOG_NOTICE);
  $form_state['redirect'] = 'admin/structure/taxonomy';
  return;
}

/**
 * Form builder to confirm resetting a vocabulary to alphabetical order.
 *
 * @ingroup forms
 * @see taxonomy_vocabulary_confirm_reset_alphabetical_submit()
 */
function taxonomy_vocabulary_confirm_reset_alphabetical($form, &$form_state, $vid) {
  $vocabulary = taxonomy_vocabulary_load($vid);

  $form['type'] = array('#type' => 'value', '#value' => 'vocabulary');
  $form['vid'] = array('#type' => 'value', '#value' => $vid);
  $form['name'] = array('#type' => 'value', '#value' => $vocabulary->name);
  $form['reset_alphabetical'] = array('#type' => 'value', '#value' => TRUE);
  return confirm_form($form,
                  t('Are you sure you want to reset the vocabulary %title to alphabetical order?',
                  array('%title' => $vocabulary->name)),
                  'admin/structure/taxonomy/' . $vid,
                  t('Resetting a vocabulary will discard all custom ordering and sort items alphabetically.'),
                  t('Reset to alphabetical'),
                  t('Cancel'));
}

/**
 * Submit handler to reset a vocabulary to alphabetical order after confirmation.
 *
 * @see taxonomy_vocabulary_confirm_reset_alphabetical()
 */
function taxonomy_vocabulary_confirm_reset_alphabetical_submit($form, &$form_state) {
  db_update('taxonomy_term_data')
    ->fields(array('weight' => 0))
    ->condition('vid', $form_state['values']['vid'])
    ->execute();
  drupal_set_message(t('Reset vocabulary %name to alphabetical order.', array('%name' => $form_state['values']['name'])));
  watchdog('taxonomy', 'Reset vocabulary %name to alphabetical order.', array('%name' => $form_state['values']['name']), WATCHDOG_NOTICE);
  $form_state['redirect'] = 'admin/structure/taxonomy/' . $form_state['values']['vid'];
}
