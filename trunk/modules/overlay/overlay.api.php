<?php
// $Id$

/**
 * @file
 * Hooks provided by the overlay module.
 */

/**
 * @addtogroup hooks
 * @{
 */

/**
 * Allow modules to act when an overlay parent window is activated.
 *
 * @return
 *   None.
 */
function hook_overlay_parent() {
  // Add our custom JavaScript.
  drupal_add_js(drupal_get_path('module', 'hook') . '/hook-overlay.js');
}

/**
 * Allow modules to act when an overlay child window is activated.
 *
 * @return
 *   None.
 */
function hook_overlay_child() {
  // Use a different theme for content administration pages.
  if (arg(0) == 'admin' && arg(1) == 'content') {
    if ($theme = variable_get('content_administration_pages_theme', FALSE)) {
      global $custom_theme;
      $custom_theme = $theme;
    }
  }
}

/**
 * @} End of "addtogroup hooks".
 */
