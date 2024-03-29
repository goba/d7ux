<?php
// $Id: registry.inc,v 1.24 2009/08/24 00:14:18 webchick Exp $

/**
 * @file
 * This file contains the code registry parser engine.
 */

/**
 * @defgroup registry Code registry
 * @{
 * The code registry engine.
 *
 * Drupal maintains an internal registry of all functions or classes in the
 * system, allowing it to lazy-load code files as needed (reducing the amount
 * of code that must be parsed on each request).
 */

/**
 * @see registry_rebuild.
 */
function _registry_rebuild() {

  // The registry serves as a central autoloader for all classes, including
  // the database query builders. However, the registry rebuild process
  // requires write ability to the database, which means having access to the
  // query builders that require the registry in order to be loaded. That
  // causes a fatal race condition. Therefore we manually include the
  // appropriate query builders for the currently active database before the
  // registry rebuild process runs.
  $connection_info = Database::getConnectionInfo();
  $driver = $connection_info['default']['driver'];
  require_once DRUPAL_ROOT . '/includes/database/query.inc';
  require_once DRUPAL_ROOT . '/includes/database/select.inc';
  require_once DRUPAL_ROOT . '/includes/database/' . $driver . '/query.inc';

  // Get current list of modules and their files.
  $modules = system_get_module_data();
  // Get the list of files we are going to parse.
  $files = array();
  foreach ($modules as &$module) {
    $dir = dirname($module->uri);

    // Store the module directory for use in hook_registry_files_alter().
    $module->dir = $dir;

    if ($module->status) {
      // Add files for enabled modules to the registry.
      foreach ($module->info['files'] as $file) {
        $files["$dir/$file"] = array('module' => $module->name, 'weight' => $module->weight);
      }
    }
  }
  foreach (file_scan_directory('includes', '/\.inc$/') as $filename => $file) {
    $files["$filename"] = array('module' => '', 'weight' => 0);
  }

  // Allow modules to manually modify the list of files before the registry
  // parses them. The $modules array provides the .info file information, which
  // includes the list of files registered to each module. Any files in the
  // list can then be added to the list of files that the registry will parse,
  // or modify attributes of a file.
  drupal_alter('registry_files', $files, $modules);
  foreach (registry_get_parsed_files() as $filename => $file) {
    // Add the file creation and modification dates to those files we have
    // already parsed.
    if (isset($files[$filename])) {
      $files[$filename]['filectime'] = $file['filectime'];
      $files[$filename]['filemtime'] = $file['filemtime'];
    }
    else {
      // Flush the registry of resources in files that are no longer on disc
      // or are in files that no installed modules require to be parsed.
      db_delete('registry')
        ->condition('filename', $filename)
        ->execute();
      db_delete('registry_file')
        ->condition('filename', $filename)
        ->execute();
    }
  }
  $parsed_files = _registry_parse_files($files);

  $unchanged_resources = array();
  $lookup_cache = array();
  if ($cache = cache_get('lookup_cache', 'cache_registry')) {
    $lookup_cache = $cache->data;
  }
  foreach ($lookup_cache as $key => $file) {
    // If the file for this cached resource is carried over unchanged from
    // the last registry build, then we can safely re-cache it.
    if ($file && in_array($file, array_keys($files)) && !in_array($file, $parsed_files)) {
      $unchanged_resources[$key] = $file;
    }
  }
  module_implements('', FALSE, TRUE);
  _registry_check_code(REGISTRY_RESET_LOOKUP_CACHE);

  cache_clear_all('*', 'cache_registry', TRUE);

  // We have some unchanged resources, warm up the cache - no need to pay
  // for looking them up again.
  if (count($unchanged_resources) > 0) {
    cache_set('lookup_cache', $unchanged_resources, 'cache_registry');
  }
}

/**
 * Return the list of files in registry_file
 */
function registry_get_parsed_files() {
  $files = array();
  // We want the result as a keyed array.
  $files = db_query("SELECT * FROM {registry_file}")->fetchAllAssoc('filename', PDO::FETCH_ASSOC);
  return $files;
}

/**
 * Parse all files that have changed since the registry was last built, and save their function and class listings.
 *
 * @param $files
 *  The list of files to check and parse.
 */
function _registry_parse_files($files) {
  $parsed_files = array();
  foreach ($files as $filename => $file) {
    $filectime = filectime($filename);
    $filemtime = filemtime($filename);
    $modified_file = !isset($file['filectime']) || !isset($file['filemtime'])
                || $filectime != $file['filectime'] || $filemtime != $file['filemtime'];
    if ($modified_file) {
      $contents = file_get_contents($filename);
      $parsed_files[] = $filename;
      // We update the filectime/filemtime after we've saved the files resources
      // rather than here, so if we don't make it through this rebuild, the next
      // run will reparse the file.
      _registry_parse_file($filename, $contents, $file['module'], $file['weight']);
      db_merge('registry_file')
        ->key(array('filename' => $filename))
        ->fields(array(
          'filectime' => $filectime,
          'filemtime' => $filemtime,
        ))
        ->execute();
    }
  }
  return $parsed_files;
}

/**
 * Parse a file and save its function and class listings.
 *
 * @param $filename
 *  Name of the file we are going to parse.
 * @param $contents
 *  Contents of the file we are going to parse as a string.
 * @param $module
 *   (optional) Name of the module this file belongs to.
 * @param $weight
 *   (optional) Weight of the module.
 */
function _registry_parse_file($filename, $contents, $module = '', $weight = 0) {
  static $map = array(T_CLASS => 'class', T_INTERFACE => 'interface');
  // Delete registry entries for this file, so we can insert the new resources.
  db_delete('registry')
    ->condition('filename', $filename)
    ->execute();
  if (preg_match_all('/^\s*(?:abstract)?\s*(class|interface)\s+([a-zA-Z0-9_]+)/m', $contents, $matches)) {
    $query = db_insert('registry')->fields(array('name', 'type', 'filename', 'module', 'weight'));
    foreach ($matches[2] as $key => $name) {
      $query->values(array(
        'name' => $name,
        'type' => $matches[1][$key],
        'filename' => $filename,
        'module' => $module,
        'weight' => $weight,
      ));
    }
    $query->execute();
  }
}

/**
 * @} End of "defgroup registry".
 */

