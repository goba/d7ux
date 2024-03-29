<?php
// $Id: block.admin.inc,v 1.57 2009/09/18 00:12:45 webchick Exp $

/**
 * @file
 * Admin page callbacks for the block module.
 */

/**
 * Menu callback for admin/structure/block.
 */
function block_admin_display($theme = NULL) {
  global $custom_theme;

  // If non-default theme configuration has been selected, set the custom theme.
  $custom_theme = isset($theme) ? $theme : variable_get('theme_default', 'garland');

  // Fetch and sort blocks.
  $blocks = _block_rehash();
  usort($blocks, '_block_compare');

  return drupal_get_form('block_admin_display_form', $blocks, $theme);
}

/**
 * Generate main blocks administration form.
 */
function block_admin_display_form($form, &$form_state, $blocks, $theme = NULL) {
  global $theme_key, $custom_theme;

  drupal_add_css(drupal_get_path('module', 'block') . '/block.css', array('preprocess' => FALSE));

  // If non-default theme configuration has been selected, set the custom theme.
  $custom_theme = isset($theme) ? $theme : variable_get('theme_default', 'garland');
  drupal_theme_initialize();

  $block_regions = system_region_list($theme_key, REGIONS_VISIBLE) + array(BLOCK_REGION_NONE => '<' . t('none') . '>');

  // Weights range from -delta to +delta, so delta should be at least half
  // of the amount of blocks present. This makes sure all blocks in the same
  // region get an unique weight.
  $weight_delta = round(count($blocks) / 2);

  // Build the form tree.
  $form['#action'] = arg(4) ? url('admin/structure/block/list/' . $theme_key) : url('admin/structure/block');
  $form['#tree'] = TRUE;

  foreach ($blocks as $i => $block) {
    $key = $block['module'] . '_' . $block['delta'];
    $form[$key]['module'] = array(
      '#type' => 'value',
      '#value' => $block['module'],
    );
    $form[$key]['delta'] = array(
      '#type' => 'value',
      '#value' => $block['delta'],
    );
    $form[$key]['info'] = array(
      '#markup' => check_plain($block['info']),
    );
    $form[$key]['theme'] = array(
      '#type' => 'hidden',
      '#value' => $theme_key,
    );
    $form[$key]['weight'] = array(
      '#type' => 'weight',
      '#default_value' => $block['weight'],
      '#delta' => $weight_delta,
    );
    $form[$key]['region'] = array(
      '#type' => 'select',
      '#default_value' => $block['region'],
      '#options' => $block_regions,
    );
    $form[$key]['configure'] = array(
      '#markup' => l(t('configure'),
      'admin/structure/block/configure/' . $block['module'] . '/' . $block['delta']),
    );
    if ($block['module'] == 'block') {
      $form[$key]['delete'] = array(
        '#markup' => l(t('delete'),
        'admin/structure/block/delete/' . $block['delta']),
      );
    }
  }
  // Do not allow disabling the main system content block.
  unset($form['system_main']['region']['#options'][BLOCK_REGION_NONE]);

  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => t('Save blocks'),
  );

  return $form;
}

/**
 * Process main blocks administration form submissions.
 */
function block_admin_display_form_submit($form, &$form_state) {
  foreach ($form_state['values'] as $block) {
    $block['status'] = (int) ($block['region'] != BLOCK_REGION_NONE);
    $block['region'] = $block['status'] ? $block['region'] : '';
    db_update('block')
      ->fields(array(
        'status' => $block['status'],
        'weight' => $block['weight'],
        'region' => $block['region'],
      ))
      ->condition('module', $block['module'])
      ->condition('delta', $block['delta'])
      ->condition('theme', $block['theme'])
      ->execute();
  }
  drupal_set_message(t('The block settings have been updated.'));
  cache_clear_all();
}

/**
 * Helper function for sorting blocks on admin/structure/block.
 *
 * Active blocks are sorted by region, then by weight.
 * Disabled blocks are sorted by name.
 */
function _block_compare($a, $b) {
  global $theme_key;
  $regions = &drupal_static(__FUNCTION__);

  // We need the region list to correctly order by region.
  if (!isset($regions)) {
    $regions = array_flip(array_keys(system_region_list($theme_key)));
    $regions[BLOCK_REGION_NONE] = count($regions);
  }

  // Separate enabled from disabled.
  $status = $b['status'] - $a['status'];
  if ($status) {
    return $status;
  }
  // Sort by region (in the order defined by theme .info file).
  if ((!empty($a['region']) && !empty($b['region'])) && ($place = ($regions[$a['region']] - $regions[$b['region']]))) {
    return $place;
  }
  // Sort by weight.
  $weight = $a['weight'] - $b['weight'];
  if ($weight) {
    return $weight;
  }
  // Sort by title.
  return strcmp($a['info'], $b['info']);
}

/**
 * Menu callback; displays the block configuration form.
 */
function block_admin_configure($form, &$form_state, $module = NULL, $delta = 0) {
  $form['module'] = array(
    '#type' => 'value',
    '#value' => $module,
  );
  $form['delta'] = array(
    '#type' => 'value',
    '#value' => $delta,
  );

  $edit = db_query("SELECT pages, visibility, custom, title FROM {block} WHERE module = :module AND delta = :delta", array(
    ':module' => $module,
    ':delta' => $delta,
  ))->fetchAssoc();

  $form['block_settings'] = array(
    '#type' => 'fieldset',
    '#title' => t('Block specific settings'),
    '#collapsible' => TRUE,
  );
  $form['block_settings']['title'] = array(
    '#type' => 'textfield',
    '#title' => t('Block title'),
    '#maxlength' => 64,
    '#description' => $module == 'block' ? t('The title of the block as shown to the user.') : t('Override the default title for the block. Use <em>&lt;none&gt;</em> to display no title, or leave blank to use the default block title.'),
    '#default_value' => $edit['title'],
    '#weight' => -18,
  );

  // Allow the user to define this block's region directly
  $form['regions'] = array(
    '#type' => 'fieldset',
    '#title' => t('Region settings'),
    '#collapsible' => TRUE,
    '#collapsed' => TRUE,
    '#description' => t('Specify in which region this block is displayed.'),
    '#tree' => TRUE,
  );

  $theme_default = variable_get('theme_default', 'garland');

  // Create a select list for each theme
  foreach (list_themes() as $theme_key => $theme) {
    // Only display enabled themes
    if ($theme->status) {
      $region = db_query("SELECT region FROM {block} WHERE module = :module AND delta = :delta AND theme = :theme", array(
        ':module' => $module,
        ':delta' => $delta,
        ':theme' => $theme_key,
      ))->fetchField();
  
      $form['regions'][$theme_key] = array(
        '#type' => 'select',
        '#title' => t('!theme region', array('!theme' => $theme->info['name'])),
        '#default_value' => (!empty($region) ? $region : BLOCK_REGION_NONE),
        '#options' => array(BLOCK_REGION_NONE => t('Disabled')) + $theme->info['regions'],
        '#expandable' => ($theme_key !== $theme_default),
        '#weight' => ($theme_key == $theme_default ? 9 : 10),
      );
    }
  }

  // Module-specific block configurations.
  if ($settings = module_invoke($module, 'block_configure', $delta)) {
    foreach ($settings as $k => $v) {
      $form['block_settings'][$k] = $v;
    }
  }

  // Get the block subject for the page title.
  $info = module_invoke($module, 'block_info');
  if (isset($info[$delta])) {
    drupal_set_title(t("'%name' block", array('%name' => $info[$delta]['info'])), PASS_THROUGH);
  }

  $form['page_vis_settings'] = array(
    '#type' => 'fieldset',
    '#title' => t('Page specific visibility settings'),
    '#collapsible' => TRUE,
    '#collapsed' => TRUE,
  );

  $access = user_access('use PHP for settings');
  if ($edit['visibility'] == 2 && !$access) {
    $form['page_vis_settings'] = array();
    $form['page_vis_settings']['visibility'] = array('#type' => 'value', '#value' => 2);
    $form['page_vis_settings']['pages'] = array('#type' => 'value', '#value' => $edit['pages']);
  }
  else {
    $options = array(t('Every page except those specified below.'), t('Only the pages specified below.'));
    $description = t("Enter one page per line as Drupal paths. The '*' character is a wildcard. Example paths are %blog for the blog page and %blog-wildcard for every personal blog. %front is the front page.", array('%blog' => 'blog', '%blog-wildcard' => 'blog/*', '%front' => '<front>'));

    if (module_exists('php') && $access) {
      $options[] = t('Show if the following PHP code returns <code>TRUE</code> (PHP-mode, experts only).');
      $description .= ' ' . t('If the PHP-mode is chosen, enter PHP code between %php. Note that executing incorrect PHP-code can break your Drupal site.', array('%php' => '<?php ?>'));
    }
    $form['page_vis_settings']['visibility'] = array(
      '#type' => 'radios',
      '#title' => t('Show block on specific pages'),
      '#options' => $options,
      '#default_value' => $edit['visibility'],
    );
    $form['page_vis_settings']['pages'] = array(
      '#type' => 'textarea',
      '#title' => t('Pages'),
      '#default_value' => $edit['pages'],
      '#description' => $description,
    );
  }

  // Role-based visibility settings.
  $default_role_options = db_query("SELECT rid FROM {block_role} WHERE module = :module AND delta = :delta", array(
    ':module' => $module,
    ':delta' => $delta,
  ))->fetchCol();
  $role_options = db_query('SELECT rid, name FROM {role} ORDER BY name')->fetchAllKeyed();
  $form['role_vis_settings'] = array(
    '#type' => 'fieldset',
    '#title' => t('Role specific visibility settings'),
    '#collapsible' => TRUE,
    '#collapsed' => TRUE,
  );
  $form['role_vis_settings']['roles'] = array(
    '#type' => 'checkboxes',
    '#title' => t('Show block for specific roles'),
    '#default_value' => $default_role_options,
    '#options' => $role_options,
    '#description' => t('Show this block only for the selected role(s). If you select no roles, the block will be visible to all users.'),
  );

  // Content type specific configuration.
  $default_type_options = db_query("SELECT type FROM {block_node_type} WHERE module = :module AND delta = :delta", array(
    ':module' => $module,
    ':delta' => $delta,
  ))->fetchCol();
  $form['content_type_vis_settings'] = array(
    '#type' => 'fieldset',
    '#title' => t('Content type specific visibility settings'),
    '#collapsible' => TRUE,
    '#collapsed' => TRUE,
  );
  $form['content_type_vis_settings']['types'] = array(
    '#type' => 'checkboxes',
    '#title' => t('Show block for specific content types'),
    '#default_value' => $default_type_options,
    '#options' => node_type_get_names(),
    '#description' => t('Show this block only when on a page displaying a post of the given type(s). If you select no types, there will be no type specific limitation.'),
  );

  // Standard block configurations.
  $form['user_vis_settings'] = array(
    '#type' => 'fieldset',
    '#title' => t('User specific visibility settings'),
    '#collapsible' => TRUE,
    '#collapsed' => TRUE,
  );
  $form['user_vis_settings']['custom'] = array(
    '#type' => 'radios',
    '#title' => t('Custom visibility settings'),
    '#options' => array(
      t('Users cannot control whether or not they see this block.'),
      t('Show this block by default, but let individual users hide it.'),
      t('Hide this block by default but let individual users show it.')
    ),
    '#description' => t('Allow individual users to customize the visibility of this block in their account settings.'),
    '#default_value' => $edit['custom'],
  );

  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => t('Save block'),
  );

  return $form;
}

function block_admin_configure_validate($form, &$form_state) {
  if ($form_state['values']['module'] == 'block') {
    $custom_block_exists = (bool) db_query_range('SELECT 1 FROM {block_custom} WHERE bid <> :bid AND info = :info', 0, 1, array(
      ':bid' => $form_state['values']['delta'],
      ':info' => $form_state['values']['info'],
    ))->fetchField();
    if (empty($form_state['values']['info']) || $custom_block_exists) {
      form_set_error('info', t('Please ensure that each block description is unique.'));
    }
  }
}

function block_admin_configure_submit($form, &$form_state) {
  if (!form_get_errors()) {
    db_update('block')
      ->fields(array(
        'visibility' => (int) $form_state['values']['visibility'],
        'pages' => trim($form_state['values']['pages']),
        'custom' => (int) $form_state['values']['custom'],
        'title' => $form_state['values']['title'],
      ))
      ->condition('module', $form_state['values']['module'])
      ->condition('delta', $form_state['values']['delta'])
      ->execute();

    db_delete('block_role')
      ->condition('module', $form_state['values']['module'])
      ->condition('delta', $form_state['values']['delta'])
      ->execute();
    $query = db_insert('block_role')->fields(array('rid', 'module', 'delta'));
    foreach (array_filter($form_state['values']['roles']) as $rid) {
      $query->values(array(
        'rid' => $rid,
        'module' => $form_state['values']['module'],
        'delta' => $form_state['values']['delta'],
      ));
    }
    $query->execute();

    db_delete('block_node_type')
      ->condition('module', $form_state['values']['module'])
      ->condition('delta', $form_state['values']['delta'])
      ->execute();
    $query = db_insert('block_node_type')->fields(array('type', 'module', 'delta'));
    foreach (array_filter($form_state['values']['types']) as $type) {
      $query->values(array(
        'type' => $type,
        'module' => $form_state['values']['module'],
        'delta' => $form_state['values']['delta'],
      ));
    }
    $query->execute();

    // Store regions per theme for this block
    foreach ($form_state['values']['regions'] as $theme => $region) {
      db_merge('block')
        ->key(array('theme' => $theme, 'delta' => $form_state['values']['delta'], 'module' => $form_state['values']['module']))
        ->fields(array(
          'region' => $region,
          'pages' => trim($form_state['values']['pages']),
          'status' => (int) ($region != BLOCK_REGION_NONE),
        ))
        ->execute();
    }

    module_invoke($form_state['values']['module'], 'block_save', $form_state['values']['delta'], $form_state['values']);
    drupal_set_message(t('The block configuration has been saved.'));
    cache_clear_all();
    $form_state['redirect'] = 'admin/structure/block';
  }
}

/**
 * Menu callback: display the custom block addition form.
 */
function block_add_block_form($form, &$form_state) {
  return block_admin_configure($form, $form_state, 'block', NULL);
}

function block_add_block_form_validate($form, &$form_state) {
  $custom_block_exists = (bool) db_query_range('SELECT 1 FROM {block_custom} WHERE info = :info', 0, 1, array(':info' => $form_state['values']['info']))->fetchField();

  if (empty($form_state['values']['info']) || $custom_block_exists) {
    form_set_error('info', t('Please ensure that each block description is unique.'));
  }
}

/**
 * Save the new custom block.
 */
function block_add_block_form_submit($form, &$form_state) {
  $delta = db_insert('block_custom')
    ->fields(array(
      'body' => $form_state['values']['body'],
      'info' => $form_state['values']['info'],
      'format' => $form_state['values']['body_format'],
    ))
    ->execute();

  $query = db_insert('block')->fields(array('visibility', 'pages', 'custom', 'title', 'module', 'theme', 'status', 'weight', 'delta', 'cache'));
  foreach (list_themes() as $key => $theme) {
    if ($theme->status) {
      $query->values(array(
        'visibility' => (int) $form_state['values']['visibility'],
        'pages' => trim($form_state['values']['pages']),
        'custom' => (int) $form_state['values']['custom'],
        'title' => $form_state['values']['title'], 
        'module' => $form_state['values']['module'],
        'theme' => $theme->name, 
        'status' => 0,
        'weight' => 0,
        'delta' => $delta, 
        'cache' => DRUPAL_NO_CACHE,
      ));
    }
  }
  $query->execute();

  $query = db_insert('block_role')->fields(array('rid', 'module', 'delta'));
  foreach (array_filter($form_state['values']['roles']) as $rid) {
    $query->values(array(
      'rid' => $rid,
      'module' => $form_state['values']['module'],
      'delta' => $delta,
    ));
  }
  $query->execute();

  $query = db_insert('block_node_type')->fields(array('type', 'module', 'delta'));
  foreach (array_filter($form_state['values']['types']) as $type) {
    $query->values(array(
      'type' => $type,
      'module' => $form_state['values']['module'],
      'delta' => $delta,
    ));
  }
  $query->execute();
  
  // Store regions per theme for this block
  foreach ($form_state['values']['regions'] as $theme => $region) {
    db_merge('block')
      ->key(array('theme' => $theme, 'delta' => $delta, 'module' => $form_state['values']['module']))
      ->fields(array(
        'region' => $region,
        'pages' => trim($form_state['values']['pages']),
        'status' => (int) ($region != BLOCK_REGION_NONE),
      ))
      ->execute();
  }

  drupal_set_message(t('The block has been created.'));
  cache_clear_all();
  $form_state['redirect'] = 'admin/structure/block';
}

/**
 * Menu callback; confirm deletion of custom blocks.
 */
function block_custom_block_delete($form, &$form_state, $bid = 0) {
  $custom_block = block_custom_block_get($bid);
  $form['info'] = array('#type' => 'hidden', '#value' => $custom_block['info'] ? $custom_block['info'] : $custom_block['title']);
  $form['bid'] = array('#type' => 'hidden', '#value' => $bid);

  return confirm_form($form, t('Are you sure you want to delete the block %name?', array('%name' => $custom_block['info'])), 'admin/structure/block', '', t('Delete'), t('Cancel'));
}

/**
 * Deletion of custom blocks.
 */
function block_custom_block_delete_submit($form, &$form_state) {
  db_delete('block_custom')
    ->condition('bid', $form_state['values']['bid'])
    ->execute();
  db_delete('block')
    ->condition('module', 'block')
    ->condition('delta', $form_state['values']['bid'])
    ->execute();
  drupal_set_message(t('The block %name has been removed.', array('%name' => $form_state['values']['info'])));
  cache_clear_all();
  $form_state['redirect'] = 'admin/structure/block';
  return;
}

/**
 * Process variables for block-admin-display.tpl.php.
 *
 * The $variables array contains the following arguments:
 * - $form
 *
 * @see block-admin-display.tpl.php
 * @see theme_block_admin_display()
 */
function template_preprocess_block_admin_display_form(&$variables) {
  global $theme_key;

  $block_regions = system_region_list($theme_key, REGIONS_VISIBLE);
  $variables['block_regions'] = $block_regions + array(BLOCK_REGION_NONE => t('Disabled'));

  foreach ($block_regions as $key => $value) {
    // Initialize an empty array for the region.
    $variables['block_listing'][$key] = array();
  }

  // Initialize disabled blocks array.
  $variables['block_listing'][BLOCK_REGION_NONE] = array();

  // Set up to track previous region in loop.
  $last_region = '';
  foreach (element_children($variables['form']) as $i) {
    $block = &$variables['form'][$i];

    // Only take form elements that are blocks.
    if (isset($block['info'])) {
      // Fetch region for current block.
      $region = $block['region']['#default_value'];

      // Set special classes needed for table drag and drop.
      $variables['form'][$i]['region']['#attributes']['class'] = array('block-region-select', 'block-region-' . $region);
      $variables['form'][$i]['weight']['#attributes']['class'] = array('block-weight', 'block-weight-' . $region);

      $variables['block_listing'][$region][$i] = new stdClass();
      $variables['block_listing'][$region][$i]->row_class = !empty($block['#attributes']['class']) ? implode(' ', $block['#attributes']['class']) : '';
      $variables['block_listing'][$region][$i]->block_modified = !empty($block['#attributes']['class']) && in_array('block-modified', $block['#attributes']['class']);
      $variables['block_listing'][$region][$i]->block_title =  drupal_render($block['info']);
      $variables['block_listing'][$region][$i]->region_select = drupal_render($block['region']) . drupal_render($block['theme']);
      $variables['block_listing'][$region][$i]->weight_select = drupal_render($block['weight']);
      $variables['block_listing'][$region][$i]->configure_link = drupal_render($block['configure']);
      $variables['block_listing'][$region][$i]->delete_link = !empty($block['delete']) ? drupal_render($block['delete']) : '';
      $variables['block_listing'][$region][$i]->printed = FALSE;

      $last_region = $region;
    }
  }

  $variables['form_submit'] = drupal_render_children($variables['form']);
}
