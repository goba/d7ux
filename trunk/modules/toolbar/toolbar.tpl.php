<?php
// $Id$

/**
 * @file
 * Default template for admin toolbar.
 *
 * Available variables:
 * - $collapsed: Boolean for whether the admin shortcuts should be collapsed.
 * - $user_menu: User account / logout links.
 * - $admin_menu: Top level management menu links.
 * - $admin_shortcuts: Convenience shortcuts from the "Admin" menu 
 *   (shown if not $collapsed).
 *
 * @see template_preprocess()
 * @see template_preprocess_admin_toolbar()
 */
?>
<div id="toolbar" class="clearfix">
  <div class="admin-menu clearfix">
    <span class="toggle <?php if (!$collapsed) print 'toggle-active' ?>"><?php print t('Show shortcuts') ?></span>
    <?php print $user_menu ?>
    <?php print $admin_menu ?>
  </div>

  <div class="admin-shortcuts clearfix <?php if ($collapsed) print 'collapsed' ?>">
    <?php print $admin_shortcuts; ?>
  </div>

  <div class="shadow"></div>
</div>
