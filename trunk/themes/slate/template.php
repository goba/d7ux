<?php
// $Id: template.php,v 1.1.2.1 2009/06/05 05:46:18 yhahn Exp $

/**
 * Page preprocessor().
 */
function slate_preprocess_page(&$vars) {
  $vars['site_name'] = !empty($vars['site_name']) ? truncate_utf8($vars['site_name'], 25, FALSE, TRUE) : '';
  $vars['primary_local_tasks'] = menu_primary_local_tasks();
  $vars['secondary_local_tasks'] = menu_secondary_local_tasks();
  $vars['primary_nav'] = isset($vars['main_menu']) ? theme('links', $vars['main_menu'], array('class' => 'links main-menu')) : FALSE;
  $vars['secondary_nav'] = isset($vars['secondary_menu']) ? theme('links', $vars['secondary_menu'], array('class' => 'links secondary-menu')) : FALSE;
  $vars['ie_styles'] = '<!--[if lt IE 7]><style type="text/css" media="screen">@import ' . path_to_theme() . '/ie6.css";</style><![endif]-->';
  $vars['back_to_site'] = l(t('Back to the live site'), '');
}

/**
 * Display the list of available node types for node creation.
 */
function slate_node_add_list($content) {
  $output = '';
  if ($content) {
    $output = '<ul class="node-type-list">';
    foreach ($content as $item) {
      $output .= '<li class="clearfix">';
      $output .= '<span class="label">' . l($item['title'], $item['href'], $item['localized_options']) . '</span>';
      $output .= '<div class="description">' . filter_xss_admin($item['description']) . '</div>';
      $output .= '</li>';
    }
    $output .= '</ul>';
  }
  return $output;
}

/**
 * Override of theme_admin_block_content().
 */
function slate_admin_block_content($content) {
  $output = '';
  if (!empty($content)) {
    foreach ($content as $k => $item) {
      $id = str_replace('/', '-', $item['href']);
      $class = ' path-' . $id;

      $content[$k]['title'] = "<span class='icon'></span>{$item['title']}";
      $content[$k]['localized_options']['html'] = TRUE;
      if (!empty($content[$k]['localized_options']['attributes']['class'])) {
        $content[$k]['localized_options']['attributes']['class'] .= $class;
      }
      else {
        $content[$k]['localized_options']['attributes']['class'] = $class;
      }
    }
    $output = system_admin_compact_mode() ? '<ul class="menu">' : '<ul class="admin-list">';
    foreach ($content as $item) {
      $output .= '<li class="leaf">';
      $output .= l($item['title'], $item['href'], $item['localized_options']);
      if (!system_admin_compact_mode()) {
        $output .= '<div class="description">' . $item['description'] . '</div>';
      }
      $output .= '</li>';
    }
    $output .= '</ul>';
  }
  return $output;
}

/**
 * Override of theme_button().
 */
function slate_button($element) {
  // Make sure not to overwrite classes.
  $class = 'form-' . $element['#button_type'];
  if (strpos($element['#id'], 'submit')) {
    $class .= ' form-button-emphasized';
  }
  if (isset($element['#attributes']['class'])) {
    $element['#attributes']['class'] = $class . ' ' . $element['#attributes']['class'];
  }
  else {
    $element['#attributes']['class'] = $class;
  }

  return '<button type="submit" ' . (empty($element['#name']) ? '' : 'name="' . $element['#name'] . '" ') . 'id="' . $element['#id'] . '" value="' . check_plain($element['#value']) . '" ' . drupal_attributes($element['#attributes']) . "><span>" . check_plain($element['#value']) . "</span></button>\n";
}

/**
 * Override of theme_tablesort_indicator().
 *
 * Use our own image versions, so they show up as black and not gray on gray.
 */
function slate_tablesort_indicator($style) {
  $theme_path = drupal_get_path('theme', 'slate');
  if ($style == "asc") {
    return theme('image', $theme_path . '/images/arrow-asc.png', t('sort icon'), t('sort ascending'));
  }
  else {
    return theme('image', $theme_path . '/images/arrow-desc.png', t('sort icon'), t('sort descending'));
  }
}

/**
 * Override of theme_pager().
 *
 * Implement "Showing 1-50 of 2345  Next 50 >" type of output.
 */
function slate_pager($tags = array(), $element = 0, $parameters = array(), $quantity = 9) {
  global $pager_page_array, $pager_total, $pager_total_items, $pager_limits;
  
  $total_items = $pager_total_items[$element];
  
  if ($total_items == 0) {
    // No items to display.
    return;
  }
  
  $total_pages = $pager_total[$element];
  $limit = $pager_limits[$element];
  $showing_min = $pager_page_array[$element] * $limit + 1;
  $showing_max = min(($pager_page_array[$element] + 1) * $limit, $total_items);
  $pager_current = $pager_page_array[$element];

  $output = '<div class="short-pager">';
  if ($pager_current > 0) {
    $page_new = pager_load_array($pager_current - 1, $element, $pager_page_array);
    $output .= '<div class="short-pager-prev">' . theme('pager_link', t('Previous @limit', array('@limit' => $limit)), $page_new, $element, $parameters, array('title' => t('Go to the previous page'))) . '</div>';
  }

  $output .= '<div class="short-pager-main">' . t('Showing @range <span class="short-pager-total">of @total</span>', array('@range' => $showing_min . ' - ' . $showing_max, '@total' => $total_items)) . '</div>';

  if (($pager_current < ($total_pages - 1)) && ($total_pages > 1)) {
    $page_new = pager_load_array($pager_current + 1, $element, $pager_page_array);
    $output .= '<div class="short-pager-next">' . theme('pager_link', t('Next @limit', array('@limit' => $limit)), $page_new, $element, $parameters, array('title' => t('Go to the next page'))) . '</div>';
  }
  $output .= '</div>';
  
  return $output;
}
