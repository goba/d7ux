<?php
// $Id: block.tpl.php,v 1.7 2009/06/12 09:02:55 dries Exp $
?>
<div id="block-<?php print $block->module . '-' . $block->delta; ?>" class="<?php print $classes; ?> clearfix">

<?php if ($action_links): ?>
  <?php print $action_links; ?>
<?php endif; ?>

<?php if (!empty($block->subject)): ?>
  <h2><?php print $block->subject ?></h2>
<?php endif;?>

  <div class="content"><?php print $content ?></div>

</div>
