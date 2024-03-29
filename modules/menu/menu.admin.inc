<?php
// $Id: menu.admin.inc,v 1.59 2009/09/18 00:12:46 webchick Exp $

/**
 * @file
 * Administrative page callbacks for menu module.
 */

/**
 * Menu callback which shows an overview page of all the custom menus and their descriptions.
 */
function menu_overview_page() {
  $result = db_query("SELECT * FROM {menu_custom} WHERE personalized = 0 ORDER BY title", array(), array('fetch' => PDO::FETCH_ASSOC));
  $header = array(t('Title'), array('data' => t('Operations'), 'colspan' => '3'));
  $rows = array();
  foreach ($result as $menu) {
    $row = array(theme('menu_admin_overview', $menu['title'], $menu['menu_name'], $menu['description']));
    $row[] = array('data' => l(t('list links'), 'admin/structure/menu-customize/' . $menu['menu_name']));
    $row[] = array('data' => l(t('edit menu'), 'admin/structure/menu-customize/' . $menu['menu_name'] . '/edit'));
    $row[] = array('data' => l(t('add link'), 'admin/structure/menu-customize/' . $menu['menu_name'] . '/add'));
    $rows[] = $row;
  }

  return theme('table', $header, $rows);
}

/**
 * Theme the menu title and description for admin page
 */
function theme_menu_admin_overview($title, $name, $description) {
  $output = check_plain($title);
  $output .= '<div class="description">' . filter_xss_admin($description) . '</div>';

  return $output;
}

/**
 * Menu callback; display the page for editing the menu tree for a given menu.
 *
 * @param $menu
 *   An array representing the menu to be edited.
 * @return
 *   A page displaying the form for editing this menu.
 */
function menu_customize_menu($menu) {
  // Cross-link menus with any personalized versions of them that belong to the
  // current logged-in user.
  if ($personalized_menu_name = menu_get_personalized_menu_name($menu['menu_name'])) {
    drupal_set_message(t('You have a personalized version of this menu which you can <a href="@url">edit instead</a>.', array('@url' => url('admin/structure/menu-customize/' . $personalized_menu_name))), 'status', FALSE);
  }
  elseif (user_access('administer menu') && ($original_menu = menu_get_original_menu($menu))) {
    drupal_set_message(t('You are editing a personalized version of the site-wide <a href="@url">%title</a> menu.', array('@url' => url('admin/structure/menu-customize/' . $original_menu['menu_name']), '%title' => $original_menu['title'])), 'status', FALSE);
  }

  // Display the form for editing the menu tree.
  return drupal_get_form('menu_overview_form', $menu);
}

/**
 * Form for editing an entire menu tree at once.
 *
 * Shows for one menu the menu links accessible to the current user and
 * relevant operations.
 */
function menu_overview_form($form, &$form_state, $menu) {
  global $menu_admin;
  $sql = "
    SELECT m.load_functions, m.to_arg_functions, m.access_callback, m.access_arguments, m.page_callback, m.page_arguments, m.title, m.title_callback, m.title_arguments, m.type, m.description, ml.*
    FROM {menu_links} ml LEFT JOIN {menu_router} m ON m.path = ml.router_path
    WHERE ml.menu_name = :menu
    ORDER BY p1 ASC, p2 ASC, p3 ASC, p4 ASC, p5 ASC, p6 ASC, p7 ASC, p8 ASC, p9 ASC";
  $result = db_query($sql, array(':menu' => $menu['menu_name']), array('fetch' => PDO::FETCH_ASSOC));
  $links = array();
  foreach ($result as $item) {
    $links[] = $item;
  }
  $tree = menu_tree_data($links);
  $node_links = array();
  menu_tree_collect_node_links($tree, $node_links);
  // We indicate that a menu administrator is running the menu access check.
  $menu_admin = TRUE;
  menu_tree_check_access($tree, $node_links);
  $menu_admin = FALSE;

  $form = array_merge($form, _menu_overview_tree_form($tree));
  $form['#menu'] =  $menu;
  if (element_children($form)) {
    $form['submit'] = array(
      '#type' => 'submit',
      '#value' => t('Save configuration'),
    );
  }
  else {
    $form['#empty_text'] = t('There are no menu links yet. <a href="@link">Add link</a>.', array('@link' => url('admin/structure/menu-customize/'. $form['#menu']['menu_name'] .'/add')));
  }
  return $form;
}

/**
 * Recursive helper function for menu_overview_form().
 */
function _menu_overview_tree_form($tree) {
  $form = &drupal_static(__FUNCTION__, array('#tree' => TRUE));
  foreach ($tree as $data) {
    $title = '';
    $item = $data['link'];
    // Don't show callbacks; these have $item['hidden'] < 0.
    if ($item && $item['hidden'] >= 0) {
      $mlid = 'mlid:' . $item['mlid'];
      $form[$mlid]['#item'] = $item;
      $form[$mlid]['#attributes'] = $item['hidden'] ? array('class' => array('menu-disabled')) : array('class' => array('menu-enabled'));
      $form[$mlid]['title']['#markup'] = l($item['title'], $item['href'], $item['localized_options']) . ($item['hidden'] ? ' (' . t('disabled') . ')' : '');
      $form[$mlid]['hidden'] = array(
        '#type' => 'checkbox',
        '#default_value' => !$item['hidden'],
      );
      $form[$mlid]['expanded'] = array(
        '#type' => 'checkbox',
        '#default_value' => $item['expanded'],
      );
      $form[$mlid]['weight'] = array(
        '#type' => 'weight',
        '#delta' => 50,
        '#default_value' => isset($form_state[$mlid]['weight']) ? $form_state[$mlid]['weight'] : $item['weight'],
      );
      $form[$mlid]['mlid'] = array(
        '#type' => 'hidden',
        '#value' => $item['mlid'],
      );
      $form[$mlid]['plid'] = array(
        '#type' => 'textfield',
        '#default_value' => isset($form_state[$mlid]['plid']) ? $form_state[$mlid]['plid'] : $item['plid'],
        '#size' => 6,
      );
      // Build a list of operations.
      $operations = array();
      $operations['edit'] = l(t('edit'), 'admin/structure/menu/item/' . $item['mlid'] . '/edit');
      // Only items created by the menu module can be deleted.
      if ($item['module'] == 'menu' || $item['updated'] == 1) {
        $operations['delete'] = l(t('delete'), 'admin/structure/menu/item/' . $item['mlid'] . '/delete');
      }
      // Set the reset column.
      elseif ($item['module'] == 'system' && $item['customized']) {
        $operations['reset'] = l(t('reset'), 'admin/structure/menu/item/' . $item['mlid'] . '/reset');
      }

      $form[$mlid]['operations'] = array();
      foreach ($operations as $op => $value) {
        $form[$mlid]['operations'][$op] = array('#markup' => $value);
      }
    }

    if ($data['below']) {
      _menu_overview_tree_form($data['below']);
    }
  }
  return $form;
}

/**
 * Submit handler for the menu overview form.
 *
 * This function takes great care in saving parent items first, then items
 * underneath them. Saving items in the incorrect order can break the menu tree.
 *
 * @see menu_overview_form()
 */
function menu_overview_form_submit($form, &$form_state) {
  // When dealing with saving menu items, the order in which these items are
  // saved is critical. If a changed child item is saved before its parent,
  // the child item could be saved with an invalid path past its immediate
  // parent. To prevent this, save items in the form in the same order they
  // are sent by $_POST, ensuring parents are saved first, then their children.
  // See http://drupal.org/node/181126#comment-632270
  $order = array_flip(array_keys($form_state['input'])); // Get the $_POST order.
  $form = array_merge($order, $form); // Update our original form with the new order.

  $updated_items = array();
  $fields = array('expanded', 'weight', 'plid');
  foreach (element_children($form) as $mlid) {
    if (isset($form[$mlid]['#item'])) {
      $element = $form[$mlid];
      // Update any fields that have changed in this menu item.
      foreach ($fields as $field) {
        if ($element[$field]['#value'] != $element[$field]['#default_value']) {
          $element['#item'][$field] = $element[$field]['#value'];
          $updated_items[$mlid] = $element['#item'];
        }
      }
      // Hidden is a special case, the value needs to be reversed.
      if ($element['hidden']['#value'] != $element['hidden']['#default_value']) {
        // Convert to integer rather than boolean due to PDO cast to string.
        $element['#item']['hidden'] = $element['hidden']['#value'] ? 0 : 1;
        $updated_items[$mlid] = $element['#item'];
      }
    }
  }

  // Save all our changed items to the database.
  foreach ($updated_items as $item) {
    $item['customized'] = 1;
    menu_link_save($item);
  }
}

/**
 * Theme the menu overview form into a table.
 *
 * @ingroup themeable
 */
function theme_menu_overview_form($form) {
  drupal_add_tabledrag('menu-overview', 'match', 'parent', 'menu-plid', 'menu-plid', 'menu-mlid', TRUE, MENU_MAX_DEPTH - 1);
  drupal_add_tabledrag('menu-overview', 'order', 'sibling', 'menu-weight');

  $header = array(
    t('Menu link'),
    array('data' => t('Enabled'), 'class' => array('checkbox')),
    array('data' => t('Show as expanded'), 'class' => array('checkbox')),
    t('Weight'),
    array('data' => t('Operations'), 'colspan' => '3'),
  );

  $rows = array();
  foreach (element_children($form) as $mlid) {
    if (isset($form[$mlid]['hidden'])) {
      $element = &$form[$mlid];
      // Build a list of operations.
      $operations = array();
      foreach (element_children($element['operations']) as $op) {
        $operations[] = drupal_render($element['operations'][$op]);
      }
      while (count($operations) < 2) {
        $operations[] = '';
      }

      // Add special classes to be used for tabledrag.js.
      $element['plid']['#attributes']['class'] = array('menu-plid');
      $element['mlid']['#attributes']['class'] = array('menu-mlid');
      $element['weight']['#attributes']['class'] = array('menu-weight');

      // Change the parent field to a hidden. This allows any value but hides the field.
      $element['plid']['#type'] = 'hidden';

      $row = array();
      $row[] = theme('indentation', $element['#item']['depth'] - 1) . drupal_render($element['title']);
      $row[] = array('data' => drupal_render($element['hidden']), 'class' => array('checkbox'));
      $row[] = array('data' => drupal_render($element['expanded']), 'class' => array('checkbox'));
      $row[] = drupal_render($element['weight']) . drupal_render($element['plid']) . drupal_render($element['mlid']);
      $row = array_merge($row, $operations);

      $row = array_merge(array('data' => $row), $element['#attributes']);
      $row['class'][] = 'draggable';
      $rows[] = $row;
    }
  }
  $output = '';
  if (empty($rows)) {
    $rows[] = array(array('data' => $form['#empty_text'], 'colspan' => '7'));
  }
  $output .= theme('table', $header, $rows, array('id' => 'menu-overview'));
  $output .= drupal_render_children($form);
  return $output;
}

/**
 * Menu callback; Build the menu link editing form.
 */
function menu_edit_item($form, &$form_state, $type, $item, $menu) {

  $form['menu'] = array(
    '#type' => 'fieldset',
    '#title' => t('Menu settings'),
    '#collapsible' => FALSE,
    '#tree' => TRUE,
    '#weight' => -2,
    '#attributes' => array('class' => array('menu-item-form')),
    '#item' => $item,
  );
  if ($type == 'add' || empty($item)) {
    // This is an add form, initialize the menu link.
    $item = array('link_title' => '', 'mlid' => 0, 'plid' => 0, 'menu_name' => $menu['menu_name'], 'weight' => 0, 'link_path' => '', 'options' => array(), 'module' => 'menu', 'expanded' => 0, 'hidden' => 0, 'has_children' => 0);
  }
  $form['menu']['link_title'] = array('#type' => 'textfield',
    '#title' => t('Menu link title'),
    '#default_value' => $item['link_title'],
    '#description' => t('The text to be used for this link in the menu.'),
    '#required' => TRUE,
  );
  foreach (array('link_path', 'mlid', 'module', 'has_children', 'options') as $key) {
    $form['menu'][$key] = array('#type' => 'value', '#value' => $item[$key]);
  }
  // Any item created or edited via this interface is considered "customized".
  $form['menu']['customized'] = array('#type' => 'value', '#value' => 1);
  $form['menu']['original_item'] = array('#type' => 'value', '#value' => $item);

  $path = $item['link_path'];
  if (isset($item['options']['query'])) {
    $path .= '?' . $item['options']['query'];
  }
  if (isset($item['options']['fragment'])) {
    $path .= '#' . $item['options']['fragment'];
  }
  if ($item['module'] == 'menu') {
    $form['menu']['link_path'] = array(
      '#type' => 'textfield',
      '#title' => t('Path'),
      '#default_value' => $path,
      '#description' => t('The path for this menu link. This can be an internal Drupal path such as %add-node or an external URL such as %drupal. Enter %front to link to the front page.', array('%front' => '<front>', '%add-node' => 'node/add', '%drupal' => 'http://drupal.org')),
      '#required' => TRUE,
    );
    $form['delete'] = array(
      '#type' => 'submit',
      '#value' => t('Delete'),
      '#access' => $item['mlid'],
      '#submit' => array('menu_item_delete_submit'),
      '#weight' => 10,
    );
  }
  else {
    $form['menu']['_path'] = array(
      '#type' => 'item',
      '#title' => t('Path'),
      '#description' => l($item['link_title'], $item['href'], $item['options']),
    );
  }
  $form['menu']['description'] = array(
    '#type' => 'textarea',
    '#title' => t('Description'),
    '#default_value' => isset($item['options']['attributes']['title']) ? $item['options']['attributes']['title'] : '',
    '#rows' => 1,
    '#description' => t('The description displayed when hovering over a menu link.'),
  );
  $form['menu']['enabled'] = array(
    '#type' => 'checkbox',
    '#title' => t('Enabled'),
    '#default_value' => !$item['hidden'],
    '#description' => t('Menu links that are not enabled will not be listed in any menu.'),
  );
  $form['menu']['expanded'] = array(
    '#type' => 'checkbox',
    '#title' => t('Show as expanded'),
    '#default_value' => $item['expanded'],
    '#description' => t('If selected and this menu link has children, the menu will always appear expanded.'),
  );

  // Store the parent of this item, if it is in a personalized menu. Switching
  // this item to a new menu will not be allowed via the UI.
  $default = $item['menu_name'] . ':' . $item['plid'];
  $parent_menu = menu_load($item['menu_name']);
  if ($parent_menu['personalized']) {
    $form['menu']['parent'] = array(
      '#type' => 'value',
      '#value' => $default,
    );
  }
  // Otherwise, generate a list of possible parents (not including this item or
  // descendants) so the user can choose a new one.
  else {
    $options = menu_parent_options(menu_get_menus(), $item);
    if (!isset($options[$default])) {
      $default = 'main-menu:0';
    }
    $form['menu']['parent'] = array(
      '#type' => 'select',
      '#title' => t('Parent link'),
      '#default_value' => $default,
      '#options' => $options,
      '#description' => t('The maximum depth for a link and all its children is fixed at !maxdepth. Some menu links may not be available as parents if selecting them would exceed this limit.', array('!maxdepth' => MENU_MAX_DEPTH)),
      '#attributes' => array('class' => array('menu-title-select')),
    );
  }
  $form['menu']['weight'] = array(
    '#type' => 'weight',
    '#title' => t('Weight'),
    '#delta' => 50,
    '#default_value' => $item['weight'],
    '#description' => t('Optional. In the menu, the heavier links will sink and the lighter links will be positioned nearer the top.'),
  );
  $form['submit'] = array('#type' => 'submit', '#value' => t('Save'));


  return $form;
}

/**
 * Validate form values for a menu link being added or edited.
 */
function menu_edit_item_validate($form, &$form_state) {
  $item = &$form_state['values']['menu'];
  $normal_path = drupal_get_normal_path($item['link_path']);
  if ($item['link_path'] != $normal_path) {
    drupal_set_message(t('The menu system stores system paths only, but will use the URL alias for display. %link_path has been stored as %normal_path', array('%link_path' => $item['link_path'], '%normal_path' => $normal_path)));
    $item['link_path'] = $normal_path;
  }
  if (!menu_path_is_external($item['link_path'])) {
    $parsed_link = parse_url($item['link_path']);
    if (isset($parsed_link['query'])) {
      $item['options']['query'] = $parsed_link['query'];
    }
    if (isset($parsed_link['fragment'])) {
      $item['options']['fragment'] = $parsed_link['fragment'];
    }
    if ($item['link_path'] != $parsed_link['path']) {
      $item['link_path'] = $parsed_link['path'];
    }
  }
  if (!trim($item['link_path']) || !menu_valid_path($item)) {
    form_set_error('link_path', t("The path '@link_path' is either invalid or you do not have access to it.", array('@link_path' => $item['link_path'])));
  }
}

/**
 * Submit function for the delete button on the menu item editing form.
 */
function menu_item_delete_submit($form, &$form_state) {
  $form_state['redirect'] = 'admin/structure/menu/item/' . $form_state['values']['menu']['mlid'] . '/delete';
}

/**
 * Process menu and menu item add/edit form submissions.
 */
function menu_edit_item_submit($form, &$form_state) {
  $item = &$form_state['values']['menu'];

  // The value of "hidden" is the opposite of the value
  // supplied by the "enabled" checkbox.
  $item['hidden'] = (int) !$item['enabled'];
  unset($item['enabled']);

  $item['options']['attributes']['title'] = $item['description'];
  list($item['menu_name'], $item['plid']) = explode(':', $item['parent']);
  if (!menu_link_save($item)) {
    drupal_set_message(t('There was an error saving the menu link.'), 'error');
  }
  $form_state['redirect'] = 'admin/structure/menu-customize/' . $item['menu_name'];
}

/**
 * Menu callback; Build the form that handles the adding/editing of a custom menu.
 */
function menu_edit_menu($form, &$form_state, $type, $menu = array()) {
  $system_menus = menu_list_system_menus();
  $menu += array('menu_name' => '', 'title' => '', 'description' => '');

  // The title of a system menu cannot be altered.
  if (isset($system_menus[$menu['menu_name']])) {
    $form['title'] = array('#type' => 'value', '#value' => $menu['title']);
  }
  else {
    $form['title'] = array(
      '#type' => 'textfield',
      '#title' => t('Title'),
      '#default_value' => $menu['title'],
      '#required' => TRUE,
      '#field_suffix' => ' <small id="edit-title-suffix">&nbsp;</small>',
    );
  }

  // The internal menu name can only be defined during initial menu creation.
  if ($type == 'edit') {
    $form['#insert'] = FALSE;
    $form['menu_name'] = array('#type' => 'value', '#value' => $menu['menu_name']);
  }
  else {
    $form['#insert'] = TRUE;
    $js_settings = array(
      'type' => 'setting',
      'data' => array(
        'machineReadableValue' => array(
          'title' => array(
            'text' => t('URL path'),
            'target' => 'menu-name',
            'searchPattern' => '[^a-z0-9]+',
            'replaceToken' => '-',
          ),
        ),
      ),
    );
    $form['menu_name'] = array(
      '#type' => 'textfield',
      '#title' => t('Menu name'),
      '#maxsize' => MENU_MAX_MENU_NAME_LENGTH_UI,
      '#description' => t('This text will be used to construct the URL for the menu. The name must contain only lowercase letters, numbers and hyphens, and must be unique.'),
      '#required' => TRUE,
      '#attached' => array(
        'js' => array(drupal_get_path('module', 'system') . '/system.js', $js_settings),
      ),
    );
  }

  $form['description'] = array(
    '#type' => 'textarea',
    '#title' => t('Description'),
    '#default_value' => $menu['description'],
  );
  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => t('Save'),
  );
  // Only custom menus may be deleted.
  $form['delete'] = array(
    '#type' => 'submit',
    '#value' => t('Delete'),
    '#access' => $type == 'edit' && !isset($system_menus[$menu['menu_name']]),
    '#submit' => array('menu_custom_delete_submit'),
  );

  return $form;
}

/**
 * Submit function for the 'Delete' button on the menu editing form.
 */
function menu_custom_delete_submit($form, &$form_state) {
  $form_state['redirect'] = 'admin/structure/menu-customize/' . $form_state['values']['menu_name'] . '/delete';
}

/**
 * Menu callback; check access and get a confirm form for deletion of a custom menu.
 */
function menu_delete_menu_page($menu) {
  // System-defined menus may not be deleted.
  $system_menus = menu_list_system_menus();
  if (isset($system_menus[$menu['menu_name']])) {
    drupal_access_denied();
    return;
  }
  return drupal_get_form('menu_delete_menu_confirm', $menu);
}

/**
 * Build a confirm form for deletion of a custom menu.
 */
function menu_delete_menu_confirm($form, &$form_state, $menu) {
  $form['#menu'] = $menu;
  $caption = '';
  $num_links = db_query("SELECT COUNT(*) FROM {menu_links} WHERE menu_name = :menu", array(':menu' => $menu['menu_name']))->fetchField();
  if ($num_links) {
    $caption .= '<p>' . format_plural($num_links, '<strong>Warning:</strong> There is currently 1 menu link in %title. It will be deleted (system-defined items will be reset).', '<strong>Warning:</strong> There are currently @count menu links in %title. They will be deleted (system-defined links will be reset).', array('%title' => $menu['title'])) . '</p>';
  }
  $caption .= '<p>' . t('This action cannot be undone.') . '</p>';
  return confirm_form($form, t('Are you sure you want to delete the custom menu %title?', array('%title' => $menu['title'])), 'admin/structure/menu-customize/' . $menu['menu_name'], $caption, t('Delete'));
}

/**
 * Delete a custom menu and all links in it.
 */
function menu_delete_menu_confirm_submit($form, &$form_state) {
  $menu = $form['#menu'];
  $form_state['redirect'] = 'admin/structure/menu';
  // System-defined menus may not be deleted - only menus defined by this module.
  $system_menus = menu_list_system_menus();
  if (isset($system_menus[$menu['menu_name']])  || !(db_query("SELECT 1 FROM {menu_custom} WHERE menu_name = :menu", array(':menu' => $menu['menu_name']))->fetchField())) {
    return;
  }
  // Reset all the menu links defined by the system via hook_menu.
  $result = db_query("SELECT * FROM {menu_links} ml INNER JOIN {menu_router} m ON ml.router_path = m.path WHERE ml.menu_name = :menu AND ml.module = 'system' ORDER BY m.number_parts ASC", array(':menu' => $menu['menu_name']), array('fetch' => PDO::FETCH_ASSOC));
  foreach ($result as $item) {
    menu_reset_item($item);
  }
  // Delete all links to the overview page for this menu.
  $result = db_query("SELECT mlid FROM {menu_links} ml WHERE ml.link_path = :link", array(':link' => 'admin/structure/menu-customize/' . $menu['menu_name']), array('fetch' => PDO::FETCH_ASSOC));
  foreach ($result as $m) {
    menu_link_delete($m['mlid']);
  }
  // Delete all the links in the menu and the menu from the list of custom menus.
  db_delete('menu_links')
    ->condition('menu_name', $menu['menu_name'])
    ->execute();
  db_delete('menu_custom')
    ->condition('menu_name', $menu['menu_name'])
    ->execute();
  // Delete all the blocks for this menu.
  if (module_exists('block')) {
    db_delete('block')
      ->condition('module', 'menu')
      ->condition('delta', $menu['menu_name'])
      ->execute();
    db_delete('block_role')
      ->condition('module', 'menu')
      ->condition('delta', $menu['menu_name'])
      ->execute();
  }
  menu_cache_clear_all();
  cache_clear_all();
  $t_args = array('%title' => $menu['title']);
  drupal_set_message(t('The custom menu %title has been deleted.', $t_args));
  watchdog('menu', 'Deleted custom menu %title and all its menu links.', $t_args, WATCHDOG_NOTICE);
}

/**
 * Validates the human and machine-readable names when adding or editing a menu.
 */
function menu_edit_menu_validate($form, &$form_state) {
  $item = $form_state['values'];
  if (preg_match('/[^a-z0-9-]/', $item['menu_name'])) {
    form_set_error('menu_name', t('The menu name may only consist of lowercase letters, numbers, and hyphens.'));
  }
  if ($form['#insert']) {
    if (strlen($item['menu_name']) > MENU_MAX_MENU_NAME_LENGTH_UI) {
      form_set_error('menu_name', format_plural(MENU_MAX_MENU_NAME_LENGTH_UI, "The menu name can't be longer than 1 character.", "The menu name can't be longer than @count characters."));
    }

    // We will add 'menu-' to the menu name to help avoid name-space conflicts.
    $item['menu_name'] = 'menu-' . $item['menu_name'];
    $custom_exists = db_query('SELECT menu_name FROM {menu_custom} WHERE menu_name = :menu', array(':menu' => $item['menu_name']))->fetchField();
    $link_exists = db_query_range("SELECT menu_name FROM {menu_links} WHERE menu_name = :menu", 0, 1, array(':menu' => $item['menu_name']))->fetchField();
    if ($custom_exists || $link_exists) {
      form_set_error('menu_name', t('The menu already exists.'));
    }
  }
}

/**
 * Submit function for adding or editing a custom menu.
 */
function menu_edit_menu_submit($form, &$form_state) {
  $menu = $form_state['values'];
  $path = 'admin/structure/menu-customize/';
  if ($form['#insert']) {
    // Add 'menu-' to the menu name to help avoid name-space conflicts.
    $menu['menu_name'] = 'menu-' . $menu['menu_name'];
    $link['link_title'] = $menu['title'];
    $link['link_path'] = $path . $menu['menu_name'];
    $link['router_path'] = $path . '%';
    $link['module'] = 'menu';
    $link['plid'] = db_query("SELECT mlid FROM {menu_links} WHERE link_path = :link AND module = :module", array(
      ':link' => 'admin/structure/menu',
      ':module' => 'system'
    ))
    ->fetchField();

    menu_link_save($link);
    db_insert('menu_custom')
      ->fields(array(
        'menu_name' => $menu['menu_name'],
        'title' => $menu['title'],
        'description' => $menu['description'],
      ))
      ->execute();
  }
  else {
    db_update('menu_custom')
      ->fields(array(
        'title' => $menu['title'],
        'description' => $menu['description'],
      ))
      ->condition('menu_name', $menu['menu_name'])
      ->execute();
    $result = db_query("SELECT mlid FROM {menu_links} WHERE link_path = :path", array(':path' => $path . $menu['menu_name']), array('fetch' => PDO::FETCH_ASSOC));
    foreach ($result as $m) {
      $link = menu_link_load($m['mlid']);
      $link['link_title'] = $menu['title'];
      menu_link_save($link);
    }
  }
  $form_state['redirect'] = $path . $menu['menu_name'];
}

/**
 * Menu callback; Check access and present a confirm form for deleting a menu link.
 */
function menu_item_delete_page($item) {
  // Links defined via hook_menu may not be deleted. Updated items are an
  // exception, as they can be broken.
  if ($item['module'] == 'system' && !$item['updated']) {
    drupal_access_denied();
    return;
  }
  return drupal_get_form('menu_item_delete_form', $item);
}

/**
 * Build a confirm form for deletion of a single menu link.
 */
function menu_item_delete_form($form, &$form_state, $item) {
  $form['#item'] = $item;
  return confirm_form($form, t('Are you sure you want to delete the custom menu link %item?', array('%item' => $item['link_title'])), 'admin/structure/menu-customize/' . $item['menu_name']);
}

/**
 * Process menu delete form submissions.
 */
function menu_item_delete_form_submit($form, &$form_state) {
  $item = $form['#item'];
  menu_link_delete($item['mlid']);
  $t_args = array('%title' => $item['link_title']);
  drupal_set_message(t('The menu link %title has been deleted.', $t_args));
  watchdog('menu', 'Deleted menu link %title.', $t_args, WATCHDOG_NOTICE);
  $form_state['redirect'] = 'admin/structure/menu-customize/' . $item['menu_name'];
}

/**
 * Menu callback; reset a single modified menu link.
 */
function menu_reset_item_confirm($form, &$form_state, $item) {
  $form['item'] = array('#type' => 'value', '#value' => $item);
  return confirm_form($form, t('Are you sure you want to reset the link %item to its default values?', array('%item' => $item['link_title'])), 'admin/structure/menu-customize/' . $item['menu_name'], t('Any customizations will be lost. This action cannot be undone.'), t('Reset'));
}

/**
 * Process menu reset item form submissions.
 */
function menu_reset_item_confirm_submit($form, &$form_state) {
  $item = $form_state['values']['item'];
  $new_item = menu_reset_item($item);
  drupal_set_message(t('The menu link was reset to its default settings.'));
  $form_state['redirect'] = 'admin/structure/menu-customize/' . $new_item['menu_name'];
}

/**
 * Menu callback; Build the form presenting menu configuration options.
 */
function menu_configure() {
  $form['intro'] = array(
    '#type' => 'item',
    '#markup' => t('The menu module allows on-the-fly creation of menu links in the content authoring forms. The following option sets the default menu in which a new link will be added.'),
  );

  $menu_options = menu_get_menus();
  $form['menu_default_node_menu'] = array(
    '#type' => 'select',
    '#title' => t('Default menu for content'),
    '#default_value' => 'main-menu',
    '#options' => $menu_options,
    '#description' => t('Choose the menu to be the default in the menu options in the content authoring form.'),
  );

  $main = variable_get('menu_main_links_source', 'main-menu');
  $main_options = array_merge($menu_options, array('' => t('No Main links')));
  $form['menu_main_links_source'] = array(
    '#type' => 'select',
    '#title' => t('Source for the Main links'),
    '#default_value' => 'main-menu',
    '#options' => $main_options,
    '#tree' => FALSE,
    '#description' => t('Select what should be displayed as the Main links (typically at the top of the page).'),
  );

  $secondary_options = array_merge($menu_options, array('' => t('No Secondary links')));
  $form["menu_secondary_links_source"] = array(
    '#type' => 'select',
    '#title' => t('Source for the Secondary links'),
    '#default_value' => 'user-menu',
    '#options' => $secondary_options,
    '#tree' => FALSE,
    '#description' => t("Select the source for the Secondary links. An advanced option allows you to use the same source for both Main links (currently %main) and Secondary links: if your source menu has two levels of hierarchy, the top level menu links will appear in the Main links, and the children of the active link will appear in the Secondary links." , array('%main' => $main_options[$main])),
  );

  return system_settings_form($form, TRUE);
}
