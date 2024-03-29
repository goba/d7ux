<?php
// $Id: install.php,v 1.210 2009/09/18 00:12:45 webchick Exp $

/**
 * Root directory of Drupal installation.
 */
define('DRUPAL_ROOT', getcwd());

require_once DRUPAL_ROOT . '/includes/install.inc';

/**
 * Global flag to indicate that site is in installation mode.
 */
define('MAINTENANCE_MODE', 'install');

/**
 * Global flag to indicate that a task should not be run during the current
 * installation request.
 *
 * This can be used to skip running an installation task when certain
 * conditions are met, even though the task may still show on the list of
 * installation tasks presented to the user. For example, the Drupal installer
 * uses this flag to skip over the database configuration form when valid
 * database connection information is already available from settings.php. It
 * also uses this flag to skip language import tasks when the installation is
 * being performed in English.
 */
define('INSTALL_TASK_SKIP', 1);

/**
 * Global flag to indicate that a task should be run on each installation
 * request that reaches it.
 *
 * This is primarily used by the Drupal installer for bootstrap-related tasks.
 */
define('INSTALL_TASK_RUN_IF_REACHED', 2);

/**
 * Global flag to indicate that a task should be run on each installation
 * request that reaches it, until the database is set up and we are able to
 * record the fact that it already ran.
 *
 * This is the default method for running tasks and should be used for most
 * tasks that occur after the database is set up; these tasks will then run
 * once and be marked complete once they are successfully finished. For
 * example, the Drupal installer uses this flag for the batch installation of
 * modules on the new site, and also for the configuration form that collects
 * basic site information and sets up the site maintenance account.
 */
define('INSTALL_TASK_RUN_IF_NOT_COMPLETED', 3);

/**
 * Install Drupal either interactively or via an array of passed-in settings.
 *
 * The Drupal installation happens in a series of steps, which may be spread
 * out over multiple page requests. Each request begins by trying to determine
 * the last completed installation step (also known as a "task"), if one is
 * available from a previous request. Control is then passed to the task
 * handler, which processes the remaining tasks that need to be run until (a)
 * an error is thrown, (b) a new page needs to be displayed, or (c) the
 * installation finishes (whichever happens first).
 *
 * @param $settings
 *   An optional array of installation settings. Leave this empty for a normal,
 *   interactive, browser-based installation intended to occur over multiple
 *   page requests. Alternatively, if an array of settings is passed in, the
 *   installer will attempt to use it to perform the installation in a single
 *   page request (optimized for the command line) and not send any output
 *   intended for the web browser. See install_state_defaults() for a list of
 *   elements that are allowed to appear in this array.
 *
 * @see install_state_defaults()
 */
function install_drupal($settings = array()) {
  global $install_state;
  // Initialize the installation state with the settings that were passed in,
  // as well as a boolean indicating whether or not this is an interactive
  // installation.
  $interactive = empty($settings);
  $install_state = $settings + array('interactive' => $interactive) + install_state_defaults();
  try {
    // Begin the page request. This adds information about the current state of
    // the Drupal installation to the passed-in array.
    install_begin_request($install_state);
    // Based on the installation state, run the remaining tasks for this page
    // request, and collect any output.
    $output = install_run_tasks($install_state);
  }
  catch (Exception $e) {
    // When an installation error occurs, either send the error to the web
    // browser or pass on the exception so the calling script can use it.
    if ($install_state['interactive']) {
      install_display_output($e->getMessage(), $install_state);
    }
    else {
      throw $e;
    }
  }
  // All available tasks for this page request are now complete. Interactive
  // installations can send output to the browser or redirect the user to the
  // next page.
  if ($install_state['interactive']) {
    if ($install_state['parameters_changed']) {
      // Redirect to the correct page if the URL parameters have changed.
      install_goto(install_redirect_url($install_state));
    }
    elseif (isset($output)) {
      // Display a page only if some output is available. Otherwise it is
      // possible that we are printing a JSON page and theme output should
      // not be shown.
      install_display_output($output, $install_state);
    }
  }
}

/**
 * Return an array of default settings for the global installation state.
 *
 * The installation state is initialized with these settings at the beginning
 * of each page request. They may evolve during the page request, but they are
 * initialized again once the next request begins.
 *
 * Non-interactive Drupal installations can override some of these default
 * settings by passing in an array to the installation script, most notably
 * 'parameters' (which contains one-time parameters such as 'profile' and
 * 'locale' that are normally passed in via the URL) and 'forms' (which can
 * be used to programmatically submit forms during the installation; the keys
 * of each element indicate the name of the installation task that the form
 * submission is for, and the values are used as the $form_state['values']
 * array that is passed on to the form submission via drupal_form_submit()).
 *
 * @see drupal_form_submit()
 */
function install_state_defaults() {
  $defaults = array(
    // The current task being processed.
    'active_task' => NULL,
    // The last task that was completed during the previous installation
    // request.
    'completed_task' => NULL,
    // This becomes TRUE only when Drupal's system module is installed.
    'database_tables_exist' => FALSE,
    // An array of forms to be programmatically submitted during the
    // installation. The keys of each element indicate the name of the
    // installation task that the form submission is for, and the values are
    // used as the $form_state['values'] array that is passed on to the form
    // submission via drupal_form_submit().
    'forms' => array(),
    // This becomes TRUE only at the end of the installation process, after
    // all available tasks have been completed and Drupal is fully installed.
    // It is used by the installer to store correct information in the database
    // about the completed installation, as well as to inform theme functions
    // that all tasks are finished (so that the task list can be displayed
    // correctly).
    'installation_finished' => FALSE,
    // Whether or not this installation is interactive. By default this will
    // be set to FALSE if settings are passed in to install_drupal().
    'interactive' => TRUE,
    // An array of available languages for the installation.
    'locales' => array(),
    // An array of parameters for the installation, pre-populated by the URL
    // or by the settings passed in to install_drupal(). This is primarily
    // used to store 'profile' (the name of the chosen installation profile)
    // and 'locale' (the name of the chosen installation language), since
    // these settings need to persist from page request to page request before
    // the database is available for storage.
    'parameters' => array(),
    // Whether or not the parameters have changed during the current page
    // request. For interactive installations, this will trigger a page
    // redirect.
    'parameters_changed' => FALSE,
    // An array of information about the chosen installation profile. This will
    // be filled in based on the profile's .info file.
    'profile_info' => array(),
    // An array of available installation profiles.
    'profiles' => array(),
    // An array of server variables that will be substituted into the global
    // $_SERVER array via drupal_override_server_variables(). Used by
    // non-interactive installations only.
    'server' => array(),
    // This becomes TRUE only when a valid database connection can be
    // established.
    'settings_verified' => FALSE,
    // Installation tasks can set this to TRUE to force the page request to
    // end (even if there is no themable output), in the case of an interactive
    // installation. This is needed only rarely; for example, it would be used
    // by an installation task that prints JSON output rather than returning a
    // themed page. The most common example of this is during batch processing,
    // but the Drupal installer automatically takes care of setting this
    // parameter properly in that case, so that individual installation tasks
    // which implement the batch API do not need to set it themselves.
    'stop_page_request' => FALSE,
    // Installation tasks can set this to TRUE to indicate that the task should
    // be run again, even if it normally wouldn't be. This can be used, for
    // example, if a single task needs to be spread out over multiple page
    // requests, or if it needs to perform some validation before allowing
    // itself to be marked complete. The most common examples of this are batch
    // processing and form submissions, but the Drupal installer automatically
    // takes care of setting this parameter properly in those cases, so that
    // individual installation tasks which implement the batch API or form API
    // do not need to set it themselves.
    'task_not_complete' => FALSE,
    // A list of installation tasks which have already been performed during
    // the current page request.
    'tasks_performed' => array(),
  );
  return $defaults;
}

/**
 * Begin an installation request, modifying the installation state as needed.
 *
 * This function performs commands that must run at the beginning of every page
 * request. It throws an exception if the installation should not proceed.
 *
 * @param $install_state
 *   An array of information about the current installation state. This is
 *   modified with information gleaned from the beginning of the page request.
 */
function install_begin_request(&$install_state) {
  // Allow command line scripts to override server variables used by Drupal.
  require_once DRUPAL_ROOT . '/includes/bootstrap.inc';
  if (!$install_state['interactive']) {
    drupal_override_server_variables($install_state['server']);
  }

  // The user agent header is used to pass a database prefix in the request when
  // running tests. However, for security reasons, it is imperative that no
  // installation be permitted using such a prefix.
  if (isset($_SERVER['HTTP_USER_AGENT']) && strpos($_SERVER['HTTP_USER_AGENT'], "simpletest") !== FALSE) {
    header($_SERVER['SERVER_PROTOCOL'] . ' 403 Forbidden');
    exit;
  }

  drupal_bootstrap(DRUPAL_BOOTSTRAP_CONFIGURATION);

  // This must go after drupal_bootstrap(), which unsets globals!
  global $conf;

  require_once DRUPAL_ROOT . '/modules/system/system.install';
  require_once DRUPAL_ROOT . '/includes/common.inc';
  require_once DRUPAL_ROOT . '/includes/file.inc';
  require_once DRUPAL_ROOT . '/includes/path.inc';

  // Set up $language, so t() caller functions will still work.
  drupal_language_initialize();

  // Load module basics (needed for hook invokes).
  include_once DRUPAL_ROOT . '/includes/module.inc';
  include_once DRUPAL_ROOT . '/includes/session.inc';
  include_once DRUPAL_ROOT . '/includes/entity.inc';
  $module_list['system']['filename'] = 'modules/system/system.module';
  $module_list['filter']['filename'] = 'modules/filter/filter.module';
  $module_list['user']['filename'] = 'modules/user/user.module';
  module_list(TRUE, FALSE, FALSE, $module_list);
  drupal_load('module', 'system');
  drupal_load('module', 'filter');
  drupal_load('module', 'user');

  // Load the cache infrastructure with the Fake Cache. Switch to the database cache
  // later if possible.
  require_once DRUPAL_ROOT . '/includes/cache.inc';
  require_once DRUPAL_ROOT . '/includes/cache-install.inc';
  $conf['cache_inc'] = 'includes/cache.inc';
  $conf['cache_default_class'] = 'DrupalFakeCache';
   
  // Prepare for themed output, if necessary. We need to run this at the
  // beginning of the page request to avoid a different theme accidentally
  // getting set.
  if ($install_state['interactive']) {
    drupal_maintenance_theme();
  }

  // Check existing settings.php.
  $install_state['settings_verified'] = install_verify_settings();

  if ($install_state['settings_verified']) {
    // Since we have a database connection, we use the normal cache system.
    // This is important, as the installer calls into the Drupal system for
    // the clean URL checks, so we should maintain the cache properly.
    unset($conf['cache_default_class']);

    // Initialize the database system. Note that the connection
    // won't be initialized until it is actually requested.
    require_once DRUPAL_ROOT . '/includes/database/database.inc';

    // Verify the last completed task in the database, if there is one.
    $task = install_verify_completed_task();
  }
  else {
    $task = NULL;

    // Since previous versions of Drupal stored database connection information
    // in the 'db_url' variable, we should never let an installation proceed if
    // this variable is defined and the settings file was not verified above
    // (otherwise we risk installing over an existing site whose settings file
    // has not yet been updated).
    if (!empty($GLOBALS['db_url'])) {
      throw new Exception(install_already_done_error());
    }
  }

  // Modify the installation state as appropriate.
  $install_state['completed_task'] = $task;
  $install_state['database_tables_exist'] = !empty($task);

  // Add any installation parameters passed in via the URL.
  $install_state['parameters'] += $_GET;

  // Validate certain core settings that are used throughout the installation.
  if (!empty($install_state['parameters']['profile'])) {
    $install_state['parameters']['profile'] = preg_replace('/[^a-zA-Z_0-9]/', '', $install_state['parameters']['profile']);
  }
  if (!empty($install_state['parameters']['locale'])) {
    $install_state['parameters']['locale'] = preg_replace('/[^a-zA-Z_0-9\-]/', '', $install_state['parameters']['locale']);
  }
}

/**
 * Run all tasks for the current installation request.
 *
 * In the case of an interactive installation, all tasks will be attempted
 * until one is reached that has output which needs to be displayed to the
 * user, or until a page redirect is required. Otherwise, tasks will be
 * attempted until the installation is finished.
 *
 * @param $install_state
 *   An array of information about the current installation state. This is
 *   passed along to each task, so it can be modified if necessary.
 * @return
 *   HTML output from the last completed task.
 */
function install_run_tasks(&$install_state) {
  do {
    // Obtain a list of tasks to perform. The list of tasks itself can be
    // dynamic (e.g., some might be defined by the installation profile,
    // which is not necessarily known until the earlier tasks have run),
    // so we regenerate the remaining tasks based on the installation state,
    // each time through the loop.
    $tasks_to_perform = install_tasks_to_perform($install_state);
    // Run the first task on the list.
    reset($tasks_to_perform);
    $task_name = key($tasks_to_perform);
    $task = array_shift($tasks_to_perform);
    $install_state['active_task'] = $task_name;
    $original_parameters = $install_state['parameters'];
    $output = install_run_task($task, $install_state);
    $install_state['parameters_changed'] = ($install_state['parameters'] != $original_parameters);
    // Store this task as having been performed during the current request,
    // and save it to the database as completed, if we need to and if the
    // database is in a state that allows us to do so. Also mark the
    // installation as 'done' when we have run out of tasks.
    if (!$install_state['task_not_complete']) {
      $install_state['tasks_performed'][] = $task_name;
      $install_state['installation_finished'] = empty($tasks_to_perform);
      if ($install_state['database_tables_exist'] && ($task['run'] == INSTALL_TASK_RUN_IF_NOT_COMPLETED || $install_state['installation_finished'])) {
        drupal_install_initialize_database();
        variable_set('install_task', $install_state['installation_finished'] ? 'done' : $task_name);
      }
    }
    // Stop when there are no tasks left. In the case of an interactive
    // installation, also stop if we have some output to send to the browser,
    // the URL parameters have changed, or an end to the page request was
    // specifically called for.
    $finished = empty($tasks_to_perform) || ($install_state['interactive'] && (isset($output) || $install_state['parameters_changed'] || $install_state['stop_page_request']));
  } while (!$finished);
  return $output;
}

/**
 * Run an individual installation task.
 *
 * @param $task
 *   An array of information about the task to be run.
 * @param $install_state
 *   An array of information about the current installation state. This is
 *   passed in by reference so that it can be modified by the task.
 * @return
 *   The output of the task function, if there is any.
 */
function install_run_task($task, &$install_state) {
  $function = $task['function'];

  if ($task['type'] == 'form') {
    require_once DRUPAL_ROOT . '/includes/form.inc';
    if ($install_state['interactive']) {
      // For interactive forms, build the form and ensure that it will not
      // redirect, since the installer handles its own redirection only after
      // marking the form submission task complete.
      $form_state = array(
        // We need to pass $install_state by reference in order for forms to
        // modify it, since the form API will use it in call_user_func_array(),
        // which requires that referenced variables be passed explicitly.
        'args' => array(&$install_state),
        'no_redirect' => TRUE,
      );
      $form = drupal_build_form($function, $form_state);
      // If a successful form submission did not occur, the form needs to be
      // rendered, which means the task is not complete yet.
      if (empty($form_state['executed'])) {
        $install_state['task_not_complete'] = TRUE;
        return drupal_render($form);
      }
      // Otherwise, return nothing so the next task will run in the same
      // request.
      return;
    }
    else {
      // For non-interactive forms, submit the form programmatically with the
      // values taken from the installation state. Throw an exception if any
      // errors were encountered.
      $form_state = array('values' => !empty($install_state['forms'][$function]) ? $install_state['forms'][$function] : array());
      drupal_form_submit($function, $form_state, $install_state);
      $errors = form_get_errors();
      if (!empty($errors)) {
        throw new Exception(implode("\n", $errors));
      }
    }
  }

  elseif ($task['type'] == 'batch') {
    // Start a new batch based on the task function, if one is not running
    // already.
    $current_batch = variable_get('install_current_batch');
    if (!$install_state['interactive'] || !$current_batch) {
      $batch = $function($install_state);
      if (empty($batch)) {
        // If the task did some processing and decided no batch was necessary,
        // there is nothing more to do here.
        return;
      }
      batch_set($batch);
      // For interactive batches, we need to store the fact that this batch
      // task is currently running. Otherwise, we need to make sure the batch
      // will complete in one page request.
      if ($install_state['interactive']) {
        variable_set('install_current_batch', $function);
      }
      else {
        $batch =& batch_get();
        $batch['progressive'] = FALSE;
      }
      // Process the batch. For progressive batches, this will redirect.
      // Otherwise, the batch will complete.
      batch_process(install_redirect_url($install_state), install_full_redirect_url($install_state));
    }
    // If we are in the middle of processing this batch, keep sending back
    // any output from the batch process, until the task is complete.
    elseif ($current_batch == $function) {
      include_once DRUPAL_ROOT . '/includes/batch.inc';
      $output = _batch_page();
      // The task is complete when we try to access the batch page and receive
      // FALSE in return, since this means we are at a URL where we are no
      // longer requesting a batch ID.
      if ($output === FALSE) {
        // Return nothing so the next task will run in the same request.
        variable_del('install_current_batch');
        return;
      }
      else {
        // We need to force the page request to end if the task is not
        // complete, since the batch API sometimes prints JSON output
        // rather than returning a themed page.
        $install_state['task_not_complete'] = $install_state['stop_page_request'] = TRUE;
        return $output;
      }
    }
  }

  else {
    // For normal tasks, just return the function result, whatever it is.
    return $function($install_state);
  }
}

/**
 * Return a list of tasks to perform during the current installation request.
 *
 * Note that the list of tasks can change based on the installation state as
 * the page request evolves (for example, if an installation profile hasn't
 * been selected yet, we don't yet know which profile tasks need to be run).
 *
 * @param $install_state
 *   An array of information about the current installation state.
 * @return
 *   A list of tasks to be performed, with associated metadata.
 */
function install_tasks_to_perform($install_state) {
  // Start with a list of all currently available tasks.
  $tasks = install_tasks($install_state);
  foreach ($tasks as $name => $task) {
    // Remove any tasks that were already performed or that never should run.
    // Also, if we started this page request with an indication of the last
    // task that was completed, skip that task and all those that come before
    // it, unless they are marked as always needing to run.
    if ($task['run'] == INSTALL_TASK_SKIP || in_array($name, $install_state['tasks_performed']) || (!empty($install_state['completed_task']) && empty($completed_task_found) && $task['run'] != INSTALL_TASK_RUN_IF_REACHED)) {
      unset($tasks[$name]);
    }
    if (!empty($install_state['completed_task']) && $name == $install_state['completed_task']) {
      $completed_task_found = TRUE;
    }
  }
  return $tasks;
}

/**
 * Return a list of all tasks the installer currently knows about.
 *
 * This function will return tasks regardless of whether or not they are
 * intended to run on the current page request. However, the list can change
 * based on the installation state (for example, if an installation profile
 * hasn't been selected yet, we don't yet know which profile tasks will be
 * available).
 *
 * @param $install_state
 *   An array of information about the current installation state.
 * @return
 *   A list of tasks, with associated metadata.
 */
function install_tasks($install_state) {
  // Determine whether translation import tasks will need to be performed.
  $needs_translations = count($install_state['locales']) > 1 && !empty($install_state['parameters']['locale']) && $install_state['parameters']['locale'] != 'en';

  // Start with the core installation tasks that run before handing control
  // to the install profile.
  $tasks = array(
    'install_select_profile' => array(
      'display_name' => st('Choose profile'),
      'display' => count($install_state['profiles']) != 1,
      'run' => INSTALL_TASK_RUN_IF_REACHED,
    ),
    'install_select_locale' => array(
      'display_name' => st('Choose language'),
      'run' => INSTALL_TASK_RUN_IF_REACHED,
    ),
    'install_load_profile' => array(
      'run' => INSTALL_TASK_RUN_IF_REACHED,
    ),
    'install_verify_requirements' => array(
      'display_name' => st('Verify requirements'),
    ),
    'install_settings_form' => array(
      'display_name' => st('Set up database'),
      'type' => 'form',
      'run' => $install_state['settings_verified'] ? INSTALL_TASK_SKIP : INSTALL_TASK_RUN_IF_NOT_COMPLETED,
    ),
    'install_system_module' => array(
    ),
    'install_bootstrap_full' => array(
      'run' => INSTALL_TASK_RUN_IF_REACHED,
    ),
    'install_profile_modules' => array(
      'display_name' => count($install_state['profiles']) == 1 ? st('Install site') : st('Install profile'),
      'type' => 'batch',
    ),
    'install_import_locales' => array(
      'display_name' => st('Set up translations'),
      'display' => $needs_translations,
      'type' => 'batch',
      'run' => $needs_translations ? INSTALL_TASK_RUN_IF_NOT_COMPLETED : INSTALL_TASK_SKIP,
    ),
    'install_configure_form' => array(
      'display_name' => st('Configure site'),
      'type' => 'form',
    ),
  );

  // Now add any tasks defined by the installation profile.
  if (!empty($install_state['parameters']['profile'])) {
    $function = $install_state['parameters']['profile'] . '_profile_tasks';
    if (function_exists($function)) {
      $result = $function($install_state);
      if (is_array($result)) {
        $tasks += $result;
      }
    }
  }

  // Finish by adding the remaining core tasks.
  $tasks += array(
    'install_import_locales_remaining' => array(
      'display_name' => st('Finish translations'),
      'display' => $needs_translations,
      'type' => 'batch',
      'run' => $needs_translations ? INSTALL_TASK_RUN_IF_NOT_COMPLETED : INSTALL_TASK_SKIP,
    ),
    'install_finished' => array(
      'display_name' => st('Finished'),
    ),
  );

  // Fill in default parameters for each task before returning the list.
  foreach ($tasks as $task_name => &$task) {
    $task += array(
      'display_name' => NULL,
      'display' => !empty($task['display_name']),
      'type' => 'normal',
      'run' => INSTALL_TASK_RUN_IF_NOT_COMPLETED,
      'function' => $task_name,
    );
  }
  return $tasks;
}

/**
 * Return a list of tasks that should be displayed to the end user.
 *
 * The output of this function is a list suitable for sending to
 * theme_task_list().
 *
 * @param $install_state
 *   An array of information about the current installation state.
 * @return
 *   A list of tasks, with keys equal to the machine-readable task name and
 *   values equal to the name that should be displayed.
 *
 * @see theme_task_list()
 */
function install_tasks_to_display($install_state) {
  $displayed_tasks = array();
  foreach (install_tasks($install_state) as $name => $task) {
    if ($task['display']) {
      $displayed_tasks[$name] = $task['display_name'];
    }
  }
  return $displayed_tasks;
}

/**
 * Return the URL that should be redirected to during an installation request.
 *
 * The output of this function is suitable for sending to install_goto().
 *
 * @param $install_state
 *   An array of information about the current installation state.
 * @return
 *   The URL to redirect to.
 *
 * @see install_full_redirect_url()
 */
function install_redirect_url($install_state) {
  return 'install.php?' . drupal_query_string_encode($install_state['parameters']);
}

/**
 * Return the complete URL that should be redirected to during an installation
 * request.
 *
 * @param $install_state
 *   An array of information about the current installation state.
 * @return
 *   The complete URL to redirect to.
 *
 * @see install_redirect_url()
 */
function install_full_redirect_url($install_state) {
  global $base_url;
  return $base_url . '/' . install_redirect_url($install_state);
}

/**
 * Display themed installer output and end the page request.
 *
 * Installation tasks should use drupal_set_title() to set the desired page
 * title, but otherwise this function takes care of theming the overall page
 * output during every step of the installation.
 *
 * @param $output
 *   The content to display on the main part of the page.
 * @param $install_state
 *   An array of information about the current installation state.
 */
function install_display_output($output, $install_state) {
  drupal_page_header();
  // Only show the task list if there is an active task; otherwise, the page
  // request has ended before tasks have even been started, so there is nothing
  // meaningful to show.
  if (isset($install_state['active_task'])) {
    // Let the theming function know when every step of the installation has
    // been completed.
    $active_task = $install_state['installation_finished'] ? NULL : $install_state['active_task'];
    drupal_add_region_content('sidebar_first', theme_task_list(install_tasks_to_display($install_state), $active_task));
  }
  print theme($install_state['database_tables_exist'] ? 'maintenance_page' : 'install_page', $output);
  exit;
}

/**
 * Installation task; verify the requirements for installing Drupal.
 *
 * @param $install_state
 *   An array of information about the current installation state.
 * @return
 *   A themed status report, or an exception if there are requirement errors.
 *   Otherwise, no output is returned, so that the next task can be run
 *   in the same page request.
 */
function install_verify_requirements(&$install_state) {
  // Check the installation requirements for Drupal and this profile.
  $requirements = install_check_requirements($install_state);

  // Verify existence of all required modules.
  $requirements += drupal_verify_profile($install_state);

  // Check the severity of the requirements reported.
  $severity = drupal_requirements_severity($requirements);

  if ($severity == REQUIREMENT_ERROR) {
    if ($install_state['interactive']) {
      drupal_set_title(st('Requirements problem'));
      $status_report = theme('status_report', $requirements);
      $status_report .= st('Check the error messages and <a href="!url">proceed with the installation</a>.', array('!url' => request_uri()));
      return $status_report;
    }
    else {
      // Throw an exception showing all unmet requirements.
      $failures = array();
      foreach ($requirements as $requirement) {
        if (isset($requirement['severity']) && $requirement['severity'] == REQUIREMENT_ERROR) {
          $failures[] = $requirement['title'] . ': ' . $requirement['value'] . "\n\n" . $requirement['description'];
        }
      }
      throw new Exception(implode("\n\n", $failures));
    }
  }
}

/**
 * Installation task; install the Drupal system module.
 *
 * @param $install_state
 *   An array of information about the current installation state.
 */
function install_system_module(&$install_state) {
  // Install system.module.
  drupal_install_system();
  // Save the list of other modules to install for the upcoming tasks.
  // variable_set() can be used now that system.module is installed and
  // Drupal is bootstrapped.
  $modules = $install_state['profile_info']['dependencies'];

  // The install profile is also a module, which needs to be installed
  // after all the dependencies have been installed.
  $modules[] = drupal_get_profile();

  variable_set('install_profile_modules', array_diff($modules, array('system')));
  $install_state['database_tables_exist'] = TRUE;
}

/**
 * Verify and return the last installation task that was completed.
 *
 * @return
 *   The last completed task, if there is one. An exception is thrown if Drupal
 *   is already installed.
 */
function install_verify_completed_task() {
  try {
    if ($result = db_query("SELECT value FROM {variable} WHERE name = :name", array('name' => 'install_task'))) {
      $task = unserialize($result->fetchField());
    }
  }
  // Do not trigger an error if the database query fails, since the database
  // might not be set up yet.
  catch (Exception $e) {
  }
  if (isset($task)) {
    if ($task == 'done') {
      throw new Exception(install_already_done_error());
    }
    return $task;
  }
}

/**
 * Verify existing settings.php
 */
function install_verify_settings() {
  global $db_prefix, $databases;

  // Verify existing settings (if any).
  if (!empty($databases)) {
    $database = $databases['default']['default'];
    drupal_static_reset('conf_path');
    $settings_file = './' . conf_path(FALSE) . '/settings.php';
    $errors = install_database_errors($database, $settings_file);
    if (empty($errors)) {
      return TRUE;
    }
  }
  return FALSE;
}

/**
 * Installation task; define a form to configure and rewrite settings.php.
 *
 * @param $form_state
 *   An associative array containing the current state of the form.
 * @param $install_state
 *   An array of information about the current installation state.
 * @return
 *   The form API definition for the database configuration form.
 */
function install_settings_form($form, &$form_state, &$install_state) {
  global $databases, $db_prefix;
  $profile = $install_state['parameters']['profile'];
  $install_locale = $install_state['parameters']['locale'];

  drupal_static_reset('conf_path');
  $conf_path = './' . conf_path(FALSE);
  $settings_file = $conf_path . '/settings.php';
  $database = isset($databases['default']['default']) ? $databases['default']['default'] : array();

  drupal_set_title(st('Database configuration'));

  $drivers = drupal_detect_database_types();

  if (!$drivers) {
    // There is no point submitting the form if there are no database drivers
    // at all, so throw an exception here.
    throw new Exception(st('Your web server does not appear to support any common database types. Check with your hosting provider to see if they offer any databases that <a href="@drupal-databases">Drupal supports</a>.', array('@drupal-databases' => 'http://drupal.org/node/270#database')));
  }
  else {
    $form['basic_options'] = array(
      '#type' => 'fieldset',
      '#title' => st('Basic options'),
    );

    $form['basic_options']['driver'] = array(
      '#type' => 'radios',
      '#title' => st('Database type'),
      '#required' => TRUE,
      '#options' => $drivers,
      '#default_value' => !empty($database['driver']) ? $database['driver'] : current(array_keys($drivers)),
      '#description' => st('The type of database your @drupal data will be stored in.', array('@drupal' => drupal_install_profile_name())),
    );
    if (count($drivers) == 1) {
      $form['basic_options']['driver']['#disabled'] = TRUE;
      $form['basic_options']['driver']['#description'] .= ' ' . st('Your PHP configuration only supports the %driver database type so it has been automatically selected.', array('%driver' => current($drivers)));
    }

    // Database name
    $form['basic_options']['database'] = array(
      '#type' => 'textfield',
      '#title' => st('Database name'),
      '#default_value' => empty($database['database']) ? '' : $database['database'],
      '#size' => 45,
      '#required' => TRUE,
      '#description' => st('The name of the database your @drupal data will be stored in. It must exist on your server before @drupal can be installed.', array('@drupal' => drupal_install_profile_name())),
    );

    // Database username
    $form['basic_options']['username'] = array(
      '#type' => 'textfield',
      '#title' => st('Database username'),
      '#default_value' => empty($database['username']) ? '' : $database['username'],
      '#size' => 45,
    );

    // Database password
    $form['basic_options']['password'] = array(
      '#type' => 'password',
      '#title' => st('Database password'),
      '#default_value' => empty($database['password']) ? '' : $database['password'],
      '#size' => 45,
    );

    $form['advanced_options'] = array(
      '#type' => 'fieldset',
      '#title' => st('Advanced options'),
      '#collapsible' => TRUE,
      '#collapsed' => TRUE,
      '#description' => st("These options are only necessary for some sites. If you're not sure what you should enter here, leave the default settings or check with your hosting provider.")
    );

    // Database host
    $form['advanced_options']['host'] = array(
      '#type' => 'textfield',
      '#title' => st('Database host'),
      '#default_value' => empty($database['host']) ? 'localhost' : $database['host'],
      '#size' => 45,
      // Hostnames can be 255 characters long.
      '#maxlength' => 255,
      '#required' => TRUE,
      '#description' => st('If your database is located on a different server, change this.'),
    );

    // Database port
    $form['advanced_options']['port'] = array(
      '#type' => 'textfield',
      '#title' => st('Database port'),
      '#default_value' => empty($database['port']) ? '' : $database['port'],
      '#size' => 45,
      // The maximum port number is 65536, 5 digits.
      '#maxlength' => 5,
      '#description' => st('If your database server is listening to a non-standard port, enter its number.'),
    );

    // Table prefix
    $db_prefix = ($profile == 'default') ? 'drupal_' : $profile . '_';
    $form['advanced_options']['db_prefix'] = array(
      '#type' => 'textfield',
      '#title' => st('Table prefix'),
      '#default_value' => '',
      '#size' => 45,
      '#description' => st('If more than one application will be sharing this database, enter a table prefix such as %prefix for your @drupal site here.', array('@drupal' => drupal_install_profile_name(), '%prefix' => $db_prefix)),
    );

    $form['save'] = array(
      '#type' => 'submit',
      '#value' => st('Save and continue'),
    );

    $form['errors'] = array();
    $form['settings_file'] = array('#type' => 'value', '#value' => $settings_file);
    $form['_database'] = array('#type' => 'value');
  }
  return $form;
}

/**
 * Form API validate for install_settings form.
 */
function install_settings_form_validate($form, &$form_state) {
  form_set_value($form['_database'], $form_state['values'], $form_state);
  $errors = install_database_errors($form_state['values'], $form_state['values']['settings_file']);
  foreach ($errors as $name => $message) {
    form_set_error($name, $message);
  }
}

/**
 * Check a database connection and return any errors.
 */
function install_database_errors($database, $settings_file) {
  global $databases;
  $errors = array();
  // Verify the table prefix
  if (!empty($database['db_prefix']) && is_string($database['db_prefix']) && !preg_match('/^[A-Za-z0-9_.]+$/', $database['db_prefix'])) {
    $errors['db_prefix'] = st('The database table prefix you have entered, %db_prefix, is invalid. The table prefix can only contain alphanumeric characters, periods, or underscores.', array('%db_prefix' => $database['db_prefix']));
  }

  if (!empty($database['port']) && !is_numeric($database['port'])) {
    $errors['db_port'] = st('Database port must be a number.');
  }

  // Check database type
  $database_types = drupal_detect_database_types();
  $driver = $database['driver'];
  if (!isset($database_types[$driver])) {
    $errors['driver'] = st("In your %settings_file file you have configured @drupal to use a %driver server, however your PHP installation currently does not support this database type.", array('%settings_file' => $settings_file, '@drupal' => drupal_install_profile_name(), '%driver' => $database['driver']));
  }
  else {
    // Run tasks associated with the database type. Any errors are caught in the
    // calling function
    $databases['default']['default'] = $database;
    try {
      db_run_tasks($database['driver']);
    } 
    catch (DatabaseTaskException $e) {
      // These are generic errors, so we do not have any specific key of the
      // database connection array to attach them to; therefore, we just put
      // them in the error array with standard numeric keys.
      $errors[] = $e->getMessage();
    }
  }
  return $errors;
}

/**
 * Form API submit for install_settings form.
 */
function install_settings_form_submit($form, &$form_state) {
  global $install_state;

  $database = array_intersect_key($form_state['values']['_database'], array_flip(array('driver', 'database', 'username', 'password', 'host', 'port')));
  // Update global settings array and save
  $settings['databases'] = array(
    'value'    => array('default' => array('default' => $database)),
    'required' => TRUE,
  );
  $settings['db_prefix'] = array(
    'value'    => $form_state['values']['db_prefix'],
    'required' => TRUE,
  );
  drupal_rewrite_settings($settings);
  // Indicate that the settings file has been verified, and check the database
  // for the last completed task, now that we have a valid connection. This
  // last step is important since we want to trigger an error if the new
  // database already has Drupal installed.
  $install_state['settings_verified'] = TRUE;
  $install_state['completed_task'] = install_verify_completed_task();
}

/**
 * Find all .profile files.
 */
function install_find_profiles() {
  return file_scan_directory('./profiles', '/\.profile$/', array('key' => 'name'));
}

/**
 * Installation task; select which profile to install.
 *
 * @param $install_state
 *   An array of information about the current installation state. The chosen
 *   profile will be added here, if it was not already selected previously, as
 *   will a list of all available profiles.
 * @return
 *   For interactive installations, a form allowing the profile to be selected,
 *   if the user has a choice that needs to be made. Otherwise, an exception is
 *   thrown if a profile cannot be chosen automatically.
 */
function install_select_profile(&$install_state) {
  $install_state['profiles'] += install_find_profiles();
  if (empty($install_state['parameters']['profile'])) {
    // Try to find a profile.
    $profile = _install_select_profile($install_state['profiles']);
    if (empty($profile)) {
      // We still don't have a profile, so display a form for selecting one.
      // Only do this in the case of interactive installations, since this is
      // not a real form with submit handlers (the database isn't even set up
      // yet), rather just a convenience method for setting parameters in the
      // URL.
      if ($install_state['interactive']) {
        include_once DRUPAL_ROOT . '/includes/form.inc';
        drupal_set_title(st('Select an installation profile'));
        return drupal_render(drupal_get_form('install_select_profile_form', $install_state['profiles']));
      }
      else {
        throw new Exception(install_no_profile_error());
      }
    }
    else {
      $install_state['parameters']['profile'] = $profile;
    }
  }
}

/**
 * Helper function for automatically selecting an installation profile from a
 * list or from a selection passed in via $_POST.
 */
function _install_select_profile($profiles) {
  if (sizeof($profiles) == 0) {
    throw new Exception(install_no_profile_error());
  }
  // Don't need to choose profile if only one available.
  if (sizeof($profiles) == 1) {
    $profile = array_pop($profiles);
    // TODO: is this right?
    require_once $profile->uri;
    return $profile->name;
  }
  else {
    foreach ($profiles as $profile) {
      if (!empty($_POST['profile']) && ($_POST['profile'] == $profile->name)) {
        return $profile->name;
      }
    }
  }
}

/**
 * Form API array definition for the profile selection form.
 *
 * @param $form_state
 *   Array of metadata about state of form processing.
 * @param $profile_files
 *   Array of .profile files, as returned from file_scan_directory().
 */
function install_select_profile_form($form, &$form_state, $profile_files) {
  $profiles = array();
  $names = array();

  foreach ($profile_files as $profile) {
    // TODO: is this right?
    include_once DRUPAL_ROOT . '/' . $profile->uri;
    
    $details = install_profile_info($profile->name);
    $profiles[$profile->name] = $details;

    // Determine the name of the profile; default to file name if defined name
    // is unspecified.
    $name = isset($details['name']) ? $details['name'] : $profile->name;
    $names[$profile->name] = $name;
  }

  // Display radio buttons alphabetically by human-readable name.
  natcasesort($names);

  foreach ($names as $profile => $name) {
    $form['profile'][$name] = array(
      '#type' => 'radio',
      '#value' => 'default',
      '#return_value' => $profile,
      '#title' => $name,
      '#description' => isset($profiles[$profile]['description']) ? $profiles[$profile]['description'] : '',
      '#parents' => array('profile'),
    );
  }
  $form['submit'] =  array(
    '#type' => 'submit',
    '#value' => st('Save and continue'),
  );
  return $form;
}

/**
 * Find all .po files for the current profile.
 */
function install_find_locales($profilename) {
  $locales = file_scan_directory('./profiles/' . $profilename . '/translations', '/\.po$/', array('recurse' => FALSE));
  array_unshift($locales, (object) array('name' => 'en'));
  return $locales;
}

/**
 * Installation task; select which locale to use for the current profile.
 *
 * @param $install_state
 *   An array of information about the current installation state. The chosen
 *   locale will be added here, if it was not already selected previously, as
 *   will a list of all available locales.
 * @return
 *   For interactive installations, a form or other page output allowing the
 *   locale to be selected or providing information about locale selection, if
 *   a locale has not been chosen. Otherwise, an exception is thrown if a
 *   locale cannot be chosen automatically.
 */
function install_select_locale(&$install_state) {
  // Find all available locales.
  $profilename = $install_state['parameters']['profile'];
  $locales = install_find_locales($profilename);
  $install_state['locales'] += $locales;
  if (empty($install_state['parameters']['locale'])) {
    // If only the built-in (English) language is available, and we are using
    // the default profile and performing an interactive installation, inform
    // the user that the installer can be localized. Otherwise we assume the
    // user knows what he is doing.
    if (count($locales) == 1) {
      if ($profilename == 'default' && $install_state['interactive']) {
        drupal_set_title(st('Choose language'));
        if (!empty($install_state['parameters']['localize'])) {
          $output = '<p>' . st('With the addition of an appropriate translation package, this installer is capable of proceeding in another language of your choice. To install and use Drupal in a language other than English:') . '</p>';
          $output .= '<ul><li>' . st('Determine if <a href="@translations" target="_blank">a translation of this Drupal version</a> is available in your language of choice. A translation is provided via a translation package; each translation package enables the display of a specific version of Drupal in a specific language. Not all languages are available for every version of Drupal.', array('@translations' => 'http://drupal.org/project/translations')) . '</li>';
          $output .= '<li>' . st('If an alternative translation package of your choice is available, download and extract its contents to your Drupal root directory.') . '</li>';
          $output .= '<li>' . st('Return to choose language using the second link below and select your desired language from the displayed list. Reloading the page allows the list to automatically adjust to the presence of new translation packages.') . '</li>';
          $output .= '</ul><p>' . st('Alternatively, to install and use Drupal in English, or to defer the selection of an alternative language until after installation, select the first link below.') . '</p>';
          $output .= '<p>' . st('How should the installation continue?') . '</p>';
          $output .= '<ul><li><a href="install.php?profile=' . $profilename . '&amp;locale=en">' . st('Continue installation in English') . '</a></li><li><a href="install.php?profile=' . $profilename . '">' . st('Return to choose a language') . '</a></li></ul>';
        }
        else {
          $output = '<ul><li><a href="install.php?profile=' . $profilename . '&amp;locale=en">' . st('Install Drupal in English') . '</a></li><li><a href="install.php?profile=' . $profilename . '&amp;localize=true">' . st('Learn how to install Drupal in other languages') . '</a></li></ul>';
        }
        return $output;
      }
      // One language, but not the default profile or not an interactive
      // installation. Assume the user knows what he is doing.
      $locale = current($locales);
      $install_state['parameters']['locale'] = $locale->name;
      return;
    }
    else {
      // Allow profile to pre-select the language, skipping the selection.
      $function = $profilename . '_profile_details';
      if (function_exists($function)) {
        $details = $function();
        if (isset($details['language'])) {
          foreach ($locales as $locale) {
            if ($details['language'] == $locale->name) {
              $install_state['parameters']['locale'] = $locale->name;
              return;
            }
          }
        }
      }

      if (!empty($_POST['locale'])) {
        foreach ($locales as $locale) {
          if ($_POST['locale'] == $locale->name) {
            $install_state['parameters']['locale'] = $locale->name;
            return;
          }
        }
      }

      // We still don't have a locale, so display a form for selecting one.
      // Only do this in the case of interactive installations, since this is
      // not a real form with submit handlers (the database isn't even set up
      // yet), rather just a convenience method for setting parameters in the
      // URL.
      if ($install_state['interactive']) {
        drupal_set_title(st('Choose language'));
        include_once DRUPAL_ROOT . '/includes/form.inc';
        return drupal_render(drupal_get_form('install_select_locale_form', $locales));
      }
      else {
        throw new Exception(st('Sorry, you must select a language to continue the installation.'));
      }
    }
  }
}

/**
 * Form API array definition for language selection.
 */
function install_select_locale_form($form, &$form_state, $locales) {
  include_once DRUPAL_ROOT . '/includes/iso.inc';
  $languages = _locale_get_predefined_list();
  foreach ($locales as $locale) {
    // Try to use verbose locale name
    $name = $locale->name;
    if (isset($languages[$name])) {
      $name = $languages[$name][0] . (isset($languages[$name][1]) ? ' ' . st('(@language)', array('@language' => $languages[$name][1])) : '');
    }
    $form['locale'][$locale->name] = array(
      '#type' => 'radio',
      '#return_value' => $locale->name,
      '#default_value' => $locale->name == 'en',
      '#title' => $name . ($locale->name == 'en' ? ' ' . st('(built-in)') : ''),
      '#parents' => array('locale')
    );
  }
  $form['submit'] =  array(
    '#type' => 'submit',
    '#value' => st('Select language'),
  );
  return $form;
}

/**
 * Indicate that there are no profiles available.
 */
function install_no_profile_error() {
  drupal_set_title(st('No profiles available'));
  return st('We were unable to find any installation profiles. Installation profiles tell us what modules to enable and what schema to install in the database. A profile is necessary to continue with the installation process.');
}

/**
 * Indicate that Drupal has already been installed.
 */
function install_already_done_error() {
  global $base_url;

  drupal_set_title(st('Drupal already installed'));
  return st('<ul><li>To start over, you must empty your existing database.</li><li>To install to a different database, edit the appropriate <em>settings.php</em> file in the <em>sites</em> folder.</li><li>To upgrade an existing installation, proceed to the <a href="@base-url/update.php">update script</a>.</li><li>View your <a href="@base-url">existing site</a>.</li></ul>', array('@base-url' => $base_url));
}

/**
 * Installation task; load information about the chosen profile.
 *
 * @param $install_state
 *   An array of information about the current installation state. The loaded
 *   profile information will be added here, or an exception will be thrown if
 *   the profile cannot be loaded.
 */
function install_load_profile(&$install_state) {
  $profile_file = DRUPAL_ROOT . '/profiles/' . $install_state['parameters']['profile'] . '/' . $install_state['parameters']['profile'] . '.profile';
  if (is_file($profile_file)) {
    include_once $profile_file;
    $install_state['profile_info'] = install_profile_info($install_state['parameters']['profile'], $install_state['parameters']['locale']);
  }
  else {
    throw new Exception(st('Sorry, the profile you have chosen cannot be loaded.'));
  }
}

/**
 * Installation task; perform a full bootstrap of Drupal.
 *
 * @param $install_state
 *   An array of information about the current installation state.
 */
function install_bootstrap_full(&$install_state) {
  // Bootstrap newly installed Drupal, while preserving existing messages.
  $messages = isset($_SESSION['messages']) ? $_SESSION['messages'] : '';
  drupal_install_initialize_database();

  drupal_bootstrap(DRUPAL_BOOTSTRAP_FULL);
  $_SESSION['messages'] = $messages;
}

/**
 * Installation task; install required modules via a batch process.
 *
 * @param $install_state
 *   An array of information about the current installation state.
 * @return
 *   The batch definition.
 */
function install_profile_modules(&$install_state) {
  $modules = variable_get('install_profile_modules', array());
  $files = system_get_module_data();
  variable_del('install_profile_modules');
  $operations = array();
  foreach ($modules as $module) {
    $operations[] = array('_install_module_batch', array($module, $files[$module]->info['name']));
  }
  $batch = array(
    'operations' => $operations,
    'title' => st('Installing @drupal', array('@drupal' => drupal_install_profile_name())),
    'error_message' => st('The installation has encountered an error.'),
  );
  return $batch;
}

/**
 * Installation task; import languages via a batch process.
 *
 * @param $install_state
 *   An array of information about the current installation state.
 * @return
 *   The batch definition, if there are language files to import.
 */
function install_import_locales(&$install_state) {
  include_once DRUPAL_ROOT . '/includes/locale.inc';
  $install_locale = $install_state['parameters']['locale'];
  // Enable installation language as default site language.
  locale_add_language($install_locale, NULL, NULL, NULL, '', NULL, 1, TRUE);
  // Collect files to import for this language.
  $batch = locale_batch_by_language($install_locale, NULL);
  if (!empty($batch)) {
    // Remember components we cover in this batch set.
    variable_set('install_locale_batch_components', $batch['#components']);
    return $batch;
  }
}

/**
 * Installation task; configure settings for the new site.
 *
 * @param $form_state
 *   An associative array containing the current state of the form.
 * @param $install_state
 *   An array of information about the current installation state.
 * @return
 *   The form API definition for the site configuration form.
 */
function install_configure_form($form, &$form_state, &$install_state) {
  if (variable_get('site_name', FALSE) || variable_get('site_mail', FALSE)) {
    // Site already configured: This should never happen, means re-running the
    // installer, possibly by an attacker after the 'install_task' variable got
    // accidentally blown somewhere. Stop it now.
    throw new Exception(install_already_done_error());
  }

  drupal_set_title(st('Configure site'));

  // Warn about settings.php permissions risk
  $settings_dir = './' . conf_path();
  $settings_file = $settings_dir . '/settings.php';
  if (!drupal_verify_install_file($settings_file, FILE_EXIST|FILE_READABLE|FILE_NOT_WRITABLE) || !drupal_verify_install_file($settings_dir, FILE_NOT_WRITABLE, 'dir')) {
    drupal_set_message(st('All necessary changes to %dir and %file have been made, so you should remove write permissions to them now in order to avoid security risks. If you are unsure how to do so, consult the <a href="@handbook_url">online handbook</a>.', array('%dir' => $settings_dir, '%file' => $settings_file, '@handbook_url' => 'http://drupal.org/server-permissions')), 'error');
  }
  else {
    drupal_set_message(st('All necessary changes to %dir and %file have been made. They have been set to read-only for security.', array('%dir' => $settings_dir, '%file' => $settings_file)));
  }

  // Add JavaScript validation.
  _user_password_dynamic_validation();
  drupal_add_js(drupal_get_path('module', 'system') . '/system.js');
  // Add JavaScript time zone detection.
  drupal_add_js('misc/timezone.js');
  // We add these strings as settings because JavaScript translation does not
  // work on install time.
  drupal_add_js(array('copyFieldValue' => array('edit-site-mail' => array('edit-account-mail'))), 'setting');
  drupal_add_js('jQuery(function () { Drupal.cleanURLsInstallCheck(); });', 'inline');
  // Add JS to show / hide the 'Email administrator about site updates' elements
  drupal_add_js('jQuery(function () { Drupal.hideEmailAdministratorCheckbox() });', 'inline');
  // Build menu to allow clean URL check.
  menu_rebuild();

  // Cache a fully-built schema. This is necessary for any invocation of
  // index.php because: (1) setting cache table entries requires schema
  // information, (2) that occurs during bootstrap before any module are
  // loaded, so (3) if there is no cached schema, drupal_get_schema() will
  // try to generate one but with no loaded modules will return nothing.
  //
  // This logically could be done during the 'install_finished' task, but the
  // clean URL check requires it now.
  drupal_get_schema(NULL, TRUE);

  // Return the form.
  return _install_configure_form($form, $form_state, $install_state);
}

/**
 * Installation task; import remaining languages via a batch process.
 *
 * @param $install_state
 *   An array of information about the current installation state.
 * @return
 *   The batch definition, if there are language files to import.
 */
function install_import_locales_remaining(&$install_state) {
  include_once DRUPAL_ROOT . '/includes/locale.inc';
  // Collect files to import for this language. Skip components already covered
  // in the initial batch set.
  $install_locale = $install_state['parameters']['locale'];
  $batch = locale_batch_by_language($install_locale, NULL, variable_get('install_locale_batch_components', array()));
  // Remove temporary variable.
  variable_del('install_locale_batch_components');
  return $batch;
}

/**
 * Installation task; perform final steps and display a 'finished' page.
 *
 * @param $install_state
 *   An array of information about the current installation state.
 * @return
 *   A message informing the user that the installation is complete.
 */
function install_finished(&$install_state) {
  drupal_set_title(st('@drupal installation complete', array('@drupal' => drupal_install_profile_name())), PASS_THROUGH);
  $messages = drupal_set_message();
  $output = '<p>' . st('Congratulations, @drupal has been successfully installed.', array('@drupal' => drupal_install_profile_name())) . '</p>';
  $output .= '<p>' . (isset($messages['error']) ? st('Review the messages above before continuing on to <a href="@url">your new site</a>.', array('@url' => url(''))) : st('You may now visit <a href="@url">your new site</a>.', array('@url' => url('')))) . '</p>';
  if (module_exists('help')) {
    $output .= '<p>' . st('For more information on configuring Drupal, refer to the <a href="@help">help section</a>.', array('@help' => url('admin/help'))) . '</p>';
  }

  // Rebuild the module and theme data, in case any newly-installed modules
  // need to modify it via hook_system_info_alter(). We need to clear the
  // theme static cache first, to make sure that the theme data is actually
  // rebuilt.
  drupal_static_reset('_system_get_theme_data');
  system_get_module_data();
  system_get_theme_data();

  // Rebuild menu and registry to get content type links registered by the
  // profile, and possibly any other menu items created through the tasks.
  menu_rebuild();

  // Rebuild the database cache of node types, so that any node types added
  // by newly installed modules are registered correctly and initialized with
  // the necessary fields.
  node_types_rebuild();

  // Register actions declared by any modules.
  actions_synchronize();

  // Randomize query-strings on css/js files, to hide the fact that this is a
  // new install, not upgraded yet.
  _drupal_flush_css_js();

  // Remember the profile which was used.
  variable_set('install_profile', drupal_get_profile());

  // Install profiles are always loaded last
  db_update('system')
    ->fields(array('weight' => 1000))
    ->condition('type', 'module')
    ->condition('name', drupal_get_profile())
    ->execute();

  // Cache a fully-built schema.
  drupal_get_schema(NULL, TRUE);

  // Run cron to populate update status tables (if available) so that users
  // will be warned if they've installed an out of date Drupal version.
  // Will also trigger indexing of profile-supplied content or feeds.
  drupal_cron_run();

  return $output;
}

/**
 * Batch callback for batch installation of modules.
 */
function _install_module_batch($module, $module_name, &$context) {
  _drupal_install_module($module);
  // We enable the installed module right away, so that the module will be
  // loaded by drupal_bootstrap in subsequent batch requests, and other
  // modules possibly depending on it can safely perform their installation
  // steps.
  module_enable(array($module));
  $context['results'][] = $module;
  $context['message'] = st('Installed %module module.', array('%module' => $module_name));
}

/**
 * Check installation requirements and report any errors.
 */
function install_check_requirements($install_state) {
  $profile = $install_state['parameters']['profile'];

  // Check the profile requirements.
  $requirements = drupal_check_profile($profile);

  // If Drupal is not set up already, we need to create a settings file.
  if (!$install_state['settings_verified']) {
    $writable = FALSE;
    $conf_path = './' . conf_path(FALSE, TRUE);
    $settings_file = $conf_path . '/settings.php';
    $file = $conf_path;
    $exists = FALSE;
    // Verify that the directory exists.
    if (drupal_verify_install_file($conf_path, FILE_EXIST, 'dir')) {
      // Check to make sure a settings.php already exists.
      $file = $settings_file;
      if (drupal_verify_install_file($settings_file, FILE_EXIST)) {
        $exists = TRUE;
        // If it does, make sure it is writable.
        $writable = drupal_verify_install_file($settings_file, FILE_READABLE|FILE_WRITABLE);
        $exists = TRUE;
      }
    }

    if (!$exists) {
      $requirements['settings file exists'] = array(
        'title'       => st('Settings file'),
        'value'       => st('The settings file does not exist.'),
        'severity'    => REQUIREMENT_ERROR,
        'description' => st('The @drupal installer requires that you create a settings file as part of the installation process. Copy the %default_file file to %file. More details about installing Drupal are available in <a href="@install_txt">INSTALL.txt</a>.', array('@drupal' => drupal_install_profile_name(), '%file' => $file, '%default_file' => $conf_path . '/default.settings.php', '@install_txt' => base_path() . 'INSTALL.txt')),
      );
    }
    else {
      $requirements['settings file exists'] = array(
        'title'       => st('Settings file'),
        'value'       => st('The %file file exists.', array('%file' => $file)),
      );
      if (!$writable) {
        $requirements['settings file writable'] = array(
          'title'       => st('Settings file'),
          'value'       => st('The settings file is not writable.'),
          'severity'    => REQUIREMENT_ERROR,
          'description' => st('The @drupal installer requires write permissions to %file during the installation process. If you are unsure how to grant file permissions, consult the <a href="@handbook_url">online handbook</a>.', array('@drupal' => drupal_install_profile_name(), '%file' => $file, '@handbook_url' => 'http://drupal.org/server-permissions')),
        );
      }
      else {
        $requirements['settings file'] = array(
          'title'       => st('Settings file'),
          'value'       => st('Settings file is writable.'),
        );
      }
    }
  }
  return $requirements;
}

/**
 * Form API array definition for site configuration.
 */
function _install_configure_form($form, &$form_state, &$install_state) {
  include_once DRUPAL_ROOT . '/includes/locale.inc';

  $form['site_information'] = array(
    '#type' => 'fieldset',
    '#title' => st('Site information'),
    '#collapsible' => FALSE,
  );
  $form['site_information']['site_name'] = array(
    '#type' => 'textfield',
    '#title' => st('Site name'),
    '#required' => TRUE,
    '#weight' => -20,
  );
  $form['site_information']['site_mail'] = array(
    '#type' => 'textfield',
    '#title' => st('Site e-mail address'),
    '#default_value' => ini_get('sendmail_from'),
    '#description' => st("Automated e-mails, such as registration information, will be sent from this address. Use an address ending in your site's domain to help prevent these e-mails from being flagged as spam."),
    '#required' => TRUE,
    '#weight' => -15,
  );
  $form['admin_account'] = array(
    '#type' => 'fieldset',
    '#title' => st('Site maintenance account'),
    '#collapsible' => FALSE,
  );

  $form['admin_account']['account']['#tree'] = TRUE;
  $form['admin_account']['account']['name'] = array('#type' => 'textfield',
    '#title' => st('Username'),
    '#maxlength' => USERNAME_MAX_LENGTH,
    '#description' => st('Spaces are allowed; punctuation is not allowed except for periods, hyphens, and underscores.'),
    '#required' => TRUE,
    '#weight' => -10,
    '#attributes' => array('class' => array('username')),
  );

  $form['admin_account']['account']['mail'] = array('#type' => 'textfield',
    '#title' => st('E-mail address'),
    '#maxlength' => EMAIL_MAX_LENGTH,
    '#required' => TRUE,
    '#weight' => -5,
  );
  $form['admin_account']['account']['pass'] = array(
    '#type' => 'password_confirm',
    '#required' => TRUE,
    '#size' => 25,
    '#weight' => 0,
  );

  $form['server_settings'] = array(
    '#type' => 'fieldset',
    '#title' => st('Server settings'),
    '#collapsible' => FALSE,
  );

  $countries = country_get_list();
  $countries = array_merge(array('' => st('No default country')), $countries);
  $form['server_settings']['site_default_country'] = array(
    '#type' => 'select',
    '#title' => t('Default country'),
    '#default_value' => variable_get('site_default_country', ''),
    '#options' => $countries,
    '#description' => st('Select the default country for the site.'),
    '#weight' => 0,
  );

  $form['server_settings']['date_default_timezone'] = array(
    '#type' => 'select',
    '#title' => st('Default time zone'),
    '#default_value' => date_default_timezone_get(),
    '#options' => system_time_zones(),
    '#description' => st('By default, dates in this site will be displayed in the chosen time zone.'),
    '#weight' => 5,
    '#attributes' => array('class' => array('timezone-detect')),
  );

  $form['server_settings']['clean_url'] = array(
    '#type' => 'hidden',
    '#default_value' => 0,
    '#attributes' => array('class' => array('install')),
  );

  $form['update_notifications'] = array(
    '#type' => 'fieldset',
    '#title' => st('Update notifications'),
    '#collapsible' => FALSE,
  );
  $form['update_notifications']['update_status_module'] = array(
    '#type' => 'checkboxes',
    '#options' => array(
      1 => st('Check for updates automatically'),
      2 => st('Receive e-mail notifications'),
    ),
    '#default_value' => array(1, 2),
    '#description' => st('The system will notify you when updates and important security releases are available for installed components. Anonymous information about your site is sent to <a href="@drupal">Drupal.org</a>.', array('@drupal' => 'http://drupal.org')),
    '#weight' => 15,
  );

  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => st('Save and continue'),
    '#weight' => 15,
  );

  // Allow the profile to alter this form. $form_state isn't available
  // here, but to conform to the hook_form_alter() signature, we pass
  // an empty array.
  $hook_form_alter = $install_state['parameters']['profile'] . '_form_alter';
  if (function_exists($hook_form_alter)) {
    $hook_form_alter($form, array(), 'install_configure');
  }
  return $form;
}

/**
 * Form API validate for the site configuration form.
 */
function install_configure_form_validate($form, &$form_state) {
  if ($error = user_validate_name($form_state['values']['account']['name'])) {
    form_error($form['admin_account']['account']['name'], $error);
  }
  if ($error = user_validate_mail($form_state['values']['account']['mail'])) {
    form_error($form['admin_account']['account']['mail'], $error);
  }
  if ($error = user_validate_mail($form_state['values']['site_mail'])) {
    form_error($form['site_information']['site_mail'], $error);
  }
}

/**
 * Form API submit for the site configuration form.
 */
function install_configure_form_submit($form, &$form_state) {
  global $user;

  variable_set('site_name', $form_state['values']['site_name']);
  variable_set('site_mail', $form_state['values']['site_mail']);
  variable_set('date_default_timezone', $form_state['values']['date_default_timezone']);
  variable_set('site_default_country', $form_state['values']['site_default_country']);

  // Enable update.module if this option was selected.
  if ($form_state['values']['update_status_module'][1]) {
    drupal_install_modules(array('update'));
 
    // Add the site maintenance account's email address to the list of
    // addresses to be notified when updates are available, if selected.
    if ($form_state['values']['update_status_module'][2]) {
      variable_set('update_notify_emails', array($form_state['values']['account']['mail']));
    }
  }

  // Turn this off temporarily so that we can pass a password through.
  variable_set('user_email_verification', FALSE);
  $form_state['old_values'] = $form_state['values'];
  $form_state['values'] = $form_state['values']['account'];

  // We precreated user 1 with placeholder values. Let's save the real values.
  $account = user_load(1);
  $merge_data = array('init' => $form_state['values']['mail'], 'roles' => array(), 'status' => 1);
  user_save($account, array_merge($form_state['values'], $merge_data));
  // Load global $user and perform final login tasks.
  $user = user_load(1);
  user_login_finalize();
  $form_state['values'] = $form_state['old_values'];
  unset($form_state['old_values']);
  variable_set('user_email_verification', TRUE);

  if (isset($form_state['values']['clean_url'])) {
    variable_set('clean_url', $form_state['values']['clean_url']);
  }

  // Record when this install ran.
  variable_set('install_time', $_SERVER['REQUEST_TIME']);
}

// TODO: This if() statement allows Drupal to be installed interactively when
// install.php is visited in a web browser, while simultaneously allowing the
// file to be included by command line scripts so that it can be used as an
// API. It should be removed after the API functions in this file have been
// moved out to a separate, reusable location.
if (php_sapi_name() != 'cli' && !empty($_SERVER['REMOTE_ADDR'])) {
  // Start the installer.
  install_drupal();
}
