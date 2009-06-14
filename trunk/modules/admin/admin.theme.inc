<?php
// $Id$

/**
 * Preprocessor for theme('admin_toolbar').
 */
function template_preprocess_admin_toolbar(&$vars) {
  $vars['user_menu'] = theme('links', $vars['admin_toolbar']['user_menu'], array('id' => 'admin-toolbar-user'));
  $vars['admin_menu'] = theme('links', $vars['admin_toolbar']['admin_menu'], array('id' => 'admin-toolbar-menu'));
  $vars['admin_links'] = theme('links', $vars['admin_toolbar']['admin_links'], array('id' => 'admin-toolbar-links'));
  $vars['collapsed'] = $vars['admin_toolbar']['collapsed'];
}
