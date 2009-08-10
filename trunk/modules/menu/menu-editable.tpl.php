<?php
// $Id$

/**
 * @file
 * Default theme implementation to display an editable menu.
 *
 * Available variables:
 * - $content: Rendered menu.
 * - $classes: String of classes to be used.
 * - $action_links: Links to actions that can be taken on this menu, such as
 *   "edit".
 *
 * @see template_preprocess()
 * @see template_preprocess_menu_editable()
 * @see template_process()
 */
?>
<div class="<?php print $classes; ?>">
  <?php print $action_links; ?>

  <?php print $content; ?>
</div>
