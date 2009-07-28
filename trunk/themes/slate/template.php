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
    foreach ($content as $key => $item) {
      $id = str_replace('/', '-', $item['href']);
      $class = ' path-' . $id;

      $content[$key]['title'] = "<span class='icon'></span>{$item['title']}";
      $content[$key]['localized_options']['html'] = TRUE;
      if (!empty($content[$key]['localized_options']['attributes']['class'])) {
        $content[$key]['localized_options']['attributes']['class'] .= $class;
      }
      else {
        $content[$key]['localized_options']['attributes']['class'] = $class;
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
