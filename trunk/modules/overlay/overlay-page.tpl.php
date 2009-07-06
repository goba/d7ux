<?php
// $Id$

/**
 * @file
 * Template file for an administration page display in an overlay.
 *
 * This template provides the same exact variables provided to page.tpl.php,
 * and serves the same purpose, with the exeption that this template does not
 * render regions such as head, left and right because the main purpose of this
 * template is to render a frame that is displayed in an administration overlay.
 *
 * @see overlay_theme_registry_alter()
 * @see overlay_preprocess_page()
 * @see template_preprocess_page()
 * @see template_preprocess()
 * @see theme()
 */

?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="<?php print $language->language; ?>" lang="<?php print $language->language; ?>" dir="<?php print $language->dir; ?>">
<head>
<?php print $head; ?>
<title><?php print (!empty($title) ? strip_tags($title) : $head_title); ?></title>
<?php print $styles; ?>
<?php print $scripts; ?>
</head>
<body>
<div class="overlay-page-wrapper">
  <div class="overlay-page-container clear-block">
    <div class="overlay-page-content">
<?php if ($show_messages && $messages): print $messages; endif; ?>
<?php if ($tabs): ?><?php print $tabs; ?><?php endif; ?>
<?php print $help; ?>
<div class="clear-block">
  <?php print $content; ?>
</div>
    </div>
  </div>
</div>
<?php print $closure; ?>
</body>
</html>
