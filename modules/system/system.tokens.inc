<?php
// $Id: system.tokens.inc,v 1.2 2009/08/25 10:27:15 dries Exp $

/**
 * @file
 * Builds placeholder replacement tokens system-wide data.
 *
 * This file handles tokens for the global 'site' token type, as well as
 * 'date' and 'file' tokens.
 */

/**
 * Implement hook_token_info().
 */
function system_token_info() {
  $types['site'] = array(
    'name' => t("Site information"),
    'description' => t("Tokens for site-wide settings and other global information."),
  );
  $types['date'] = array(
    'name' => t("Dates"),
    'description' => t("Tokens related to times and dates."),
  );
  $types['file'] = array(
    'name' => t("Files"),
    'description' => t("Tokens related to uploaded files."),
    'needs-data' => 'file',
  );

  // Site-wide global tokens.
  $site['name'] = array(
    'name' => t("Name"),
    'description' => t("The name of the site."),
  );
  $site['slogan'] = array(
    'name' => t("Slogan"),
    'description' => t("The slogan of the site."),
  );
  $site['mission'] = array(
    'name' => t("Mission"),
    'description' => t("The optional 'mission' of the site."),
  );
  $site['mail'] = array(
    'name' => t("Email"),
    'description' => t("The administrative email address for the site."),
  );
  $site['url'] = array(
    'name' => t("URL"),
    'description' => t("The URL of the site's front page."),
  );
  $site['login-url'] = array(
    'name' => t("Login page"),
    'description' => t("The URL of the site's login page."),
  );

  // Date related tokens.
  $date['short'] = array(
    'name' => t("Short format"),
    'description' => t("A date in 'short' format. (%date)", array('%date' => format_date(REQUEST_TIME, 'short'))),
  );
  $date['medium'] = array(
    'name' => t("Medium format"),
    'description' => t("A date in 'medium' format. (%date)", array('%date' => format_date(REQUEST_TIME, 'medium'))),
  );
  $date['long'] = array(
    'name' => t("Long format"),
    'description' => t("A date in 'long' format. (%date)", array('%date' => format_date(REQUEST_TIME, 'long'))),
  );
  $date['custom'] = array(
    'name' => t("Custom format"),
    'description' => t("A date in a custom format. See !php-date for details.", array('!php-date' => l(t('the PHP documentation'), 'http://php.net/manual/en/function.date.php'))),
  );
  $date['since'] = array(
    'name' => t("Time-since"),
    'description' => t("A data in 'time-since' format. (%date)", array('%date' => format_interval(REQUEST_TIME - 360, 2))),
  );
  $date['raw'] = array(
    'name' => t("Raw timestamp"),
    'description' => t("A date in UNIX timestamp format (%date)", array('%date' => REQUEST_TIME)),
  );


  // File related tokens.
  $file['fid'] = array(
    'name' => t("File ID"),
    'description' => t("The unique ID of the uploaded file."),
  );
  $file['uid'] = array(
    'name' => t("User ID"),
    'description' => t("The unique ID of the user who owns the file."),
  );
  $file['nid'] = array(
    'name' => t("Node ID"),
    'description' => t("The unique ID of the node the file is attached to."),
  );
  $file['name'] = array(
    'name' => t("File name"),
    'description' => t("The name of the file on disk."),
  );
  $file['description'] = array(
    'name' => t("Description"),
    'description' => t("An optional human-readable description of the file."),
  );
  $file['path'] = array(
    'name' => t("Path"),
    'description' => t("The location of the file on disk."),
  );
  $file['mime'] = array(
    'name' => t("MIME type"),
    'description' => t("The MIME type of the file."),
  );
  $file['size'] = array(
    'name' => t("File size"),
    'description' => t("The size of the file, in kilobytes."),
  );
  $file['path'] = array(
    'name' => t("URL"),
    'description' => t("The web-accessible URL for the file."),
  );
  $file['timestamp'] = array(
    'name' => t("Timestamp"),
    'description' => t("The date the file was most recently changed."),
    'type' => 'date',
  );
  $file['node'] = array(
    'name' => t("Node"),
    'description' => t("The node the file is attached to."),
    'type' => 'date',
  );
  $file['owner'] = array(
    'name' => t("Owner"),
    'description' => t("The user who originally uploaded the file."),
    'type' => 'user',
  );

  return array(
    'types' => $types,
    'tokens' => array(
      'site' => $site,
      'date' => $date,
      'file' => $file,
    ),
  );
}

/**
 * Implement hook_tokens().
 */
function system_tokens($type, $tokens, array $data = array(), array $options = array()) {
  $url_options = array('absolute' => TRUE);
  if (isset($language)) {
    $url_options['language'] = $language;
  }
  $sanitize = !empty($options['sanitize']);

  $replacements = array();

  if ($type == 'site') {
    foreach ($tokens as $name => $original) {
      switch ($name) {
        case 'name':
          $site_name = variable_get('site_name', 'Drupal');
          $replacements[$original] = $sanitize ? check_plain($site_name) : $site_name;
          break;

        case 'slogan':
          $slogan = variable_get('site_slogan', '');
          $replacements[$original] = $sanitize ? check_plain($slogan) : $slogan;
          break;

        case 'mission':
          $mission = variable_get('site_mission', '');
          $replacements[$original] = $sanitize ? filter_xss($mission) : $mission;
          break;

        case 'mail':
          $replacements[$original] = variable_get('site_mail', '');
          break;

        case 'url':
          $replacements[$original] = url('<front>', $url_options);
          break;

        case 'login-url':
          $replacements[$original] = url('user', $url_options);
          break;
      }
    }
  }

  elseif ($type == 'date') {
    if (empty($data['date'])) {
      $date = REQUEST_TIME;
    }
    else {
      $date = $data['date'];
    }
    $langcode = (isset($language) ? $language->language : NULL);

    foreach ($tokens as $name => $original) {
      switch ($name) {
        case 'raw':
          $replacements[$original] = filter_xss($date);
          break;

        case 'short':
          $replacements[$original] = format_date($date, 'short', '', NULL, $langcode);
          break;

        case 'medium':
          $replacements[$original] = format_date($date, 'medium', '', NULL, $langcode);
          break;

        case 'long':
          $replacements[$original] = format_date($date, 'long', '', NULL, $langcode);
          break;

        case 'since':
          $replacements[$original] = format_interval((REQUEST_TIME - $date), 2, $langcode);
          break;
      }
    }

    if ($created_tokens = token_find_with_prefix($tokens, 'custom')) {
      foreach ($created_tokens as $name => $original) {
        $replacements[$original] = format_date($date, 'custom', $name, NULL, $langcode);
      }
    }
  }

  elseif ($type == 'file' && !empty($data['file'])) {
    $file = $data['file'];

    foreach ($tokens as $name => $original) {
      switch ($name) {
        // Basic keys and values.
        case 'fid':
          $replacements[$original] = $file->fid;
          break;

        case 'uid':
          $replacements[$original] = $file->uid;
          break;

        case 'nid':
          $replacements[$original] = $file->nid;
          break;

        // Essential file data
        case 'name':
          $replacements[$original] = $sanitize ? check_plain($file->filename) : $file->filename;
          break;

        case 'description':
          $replacements[$original] = $sanitize ? filter_xss($file->description) : $file->description;
          break;

        case 'path':
          $replacements[$original] = $sanitize ? filter_xss($file->filepath) : $file->filepath;
          break;

        case 'mime':
          $replacements[$original] = $sanitize ? filter_xss($file->filemime) : $file->filemime;
          break;

        case 'size':
          $replacements[$original] = format_size($file->filesize);
          break;

        case 'url':
          $replacements[$original] = url(file_create_url($file->filepath), $url_options);
          break;

        // These tokens are default variations on the chained tokens handled below.
        case 'node':
          if ($nid = $file->nid) {
            $node = node_load($file->nid);
            $replacements[$original] = $sanitize ? filter_xss($node->title) : $node->title;
          }
          break;

        case 'timestamp':
          $replacements[$original] = format_date($file->timestamp, 'medium', '', NULL, (isset($language) ? $language->language : NULL));
          break;

        case 'owner':
          $account = user_load($file->uid);
          $replacements[$original] = $sanitize ? filter_xss($user->name) : $user->name;
          break;
      }
    }

    if ($node_tokens = token_find_with_prefix($tokens, 'node')) {
      $node = node_load($file->nid);
      $replacements += token_generate('node', $node_tokens, array('node' => $node), $language, $sanitize);
    }

    if ($date_tokens = token_find_with_prefix($tokens, 'timestamp')) {
      $replacements += token_generate('date', $date_tokens, array('date' => $file->timestamp), $language, $sanitize);
    }

    if (($owner_tokens = token_find_with_prefix($tokens, 'owner')) && $account = user_load($file->uid)) {
      $replacements += token_generate('user', $owner_tokens, array('user' => $account), $language, $sanitize);
    }
  }

  return $replacements;
}
