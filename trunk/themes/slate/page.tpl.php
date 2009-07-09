<?php
// $Id$
?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="<?php print $language->language; ?>" dir="<?php print $language->dir; ?>">
  <head>
    <?php print $head; ?>
    <?php print $styles; ?>
    <?php print $scripts; ?>
    <!--[if lt IE 7]><?php print $ie_styles ?><![endif]-->
    <title><?php print $head_title ?></title>
  </head>
  <body class="<?php print $classes; ?>">

  <?php if (!empty($admin)): ?><?php print $admin; ?><?php endif; ?>

  <?php if ($help): ?>
    <div id="help" class="reverse limiter">
      <div class="help-label"><?php print t('Help') ?></div>
      <div class="help-wrapper clearfix limiter"><?php print $help; ?></div>
    </div>
  <?php endif; ?>

  <?php if ($page_top): ?>
    <div id="page-top-region" class="clearfix">
      <?php print $page_top; ?>
    </div>
  <?php endif; ?>

  <?php if ($header): ?>
    <div id="header-region" class="clearfix">
      <?php print $header; ?>
    </div>
  <?php endif; ?>

  <div id="branding" class="clearfix reverse">
    <?php if ($site_name): ?><h1 class="site-name"><?php print $site_name; ?></h1><?php endif; ?>
    <?php if ($title): ?><h2 class="page-title"><?php print $title ?></h2><?php endif; ?>
    <?php if ($primary_local_tasks): ?><ul class="tabs primary"><?php print $primary_local_tasks ?></ul><?php endif; ?>
    <?php if ($help): ?><?php print l(t('Need help?'), 'admin/help', array('attributes' => array('class' => 'help-toggle'))); ?><?php endif; ?>
  </div>

  <div id="page">
    <?php if ($secondary_local_tasks): ?><ul class="tabs secondary"><?php print $secondary_local_tasks; ?></ul><?php endif; ?>

    <div id="content" class="clearfix">
      <?php if ($show_messages && $messages): ?>
        <div id="console" class="clearfix"><?php print $messages; ?></div>
      <?php endif; ?>
      <?php if ($highlight): ?><div id="highlight"><?php print $highlight ?></div><?php endif; ?>
      <?php print $content; ?>
    </div>

    <div id="footer">
      <?php print $feed_icons; ?>
      <?php print $footer; ?>
    </div>

  </div>

  <?php print $closure ?>

  </body>
</html>
