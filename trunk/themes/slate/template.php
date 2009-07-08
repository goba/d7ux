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
  $vars['ie_styles'] = '<style type="text/css" media="screen">@import ' . path_to_theme() . '/ie6.css";</style>';
  $vars['clases_array'][] = 'admin';
}

/**
 * Display the list of available node types for node creation.
 */
function slate_node_add_list($content) {
  $output = '';
  if ($content) {
    $output = '<ul class="node-type-list">';
    foreach ($content as $item) {
      $output .= '<li class="clear-block">';
      $output .= '<label>' . l($item['title'], $item['href'], $item['localized_options']) . '</label>';
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
