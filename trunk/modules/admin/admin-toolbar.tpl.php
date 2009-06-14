<?php
// $Id$

/**
 * @file
 * Default template for header admin toolbar.
 *
 * Available variables:
 * - $collapsed: Boolean for whether the admin links should be collapsed.
 * - $user_menu: User account / logout links.
 * - $admin_menu: Management menu links.
 * - $admin_links: Convenience links from the "Admin" menu.
 *
 * @see template_preprocess()
 * @see template_preprocess_admin_toolbar()
 */
?>
<div id='admin-toolbar' class='clearfix'>
  <div class='admin-menu clearfix'>
    <span class='toggle <?php if (!$collapsed) print 'toggle-active' ?>'><?php print t('Admin links') ?></span>
    <?php print $user_menu ?>
    <?php print $admin_menu ?>
  </div>

  <div class='admin-links clearfix <?php if ($collapsed) print 'collapsed' ?>'>
    <?php print $admin_links; ?>
  </div>

  <div class='shadow'></div>
</div>
