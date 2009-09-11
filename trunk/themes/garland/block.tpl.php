<?php
// $Id: block.tpl.php,v 1.9 2009/09/11 06:48:03 dries Exp $
?>
<div id="block-<?php print $block->module . '-' . $block->delta; ?>" class="<?php print $classes; ?> clearfix"<?php print $attributes; ?>>

<?php if ($admin_links): ?>
  <?php print $admin_links; ?>
<?php endif; ?>

<?php if (!empty($block->subject)): ?>
  <h2 class="title"<?php print $title_attributes; ?>><?php print $block->subject ?></h2>
<?php endif;?>

  <div class="content"><?php print $content ?></div>
</div>
