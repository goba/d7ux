<?php
// $Id: statistics.pages.inc,v 1.16 2009/08/25 10:27:15 dries Exp $

/**
 * @file
 * User page callbacks for the statistics module.
 */

function statistics_node_tracker() {
  if ($node = node_load(arg(1))) {

    $header = array(
        array('data' => t('Time'), 'field' => 'a.timestamp', 'sort' => 'desc'),
        array('data' => t('Referrer'), 'field' => 'a.url'),
        array('data' => t('User'), 'field' => 'u.name'),
        array('data' => t('Operations')));

    $query = db_select('accesslog', 'a')->extend('PagerDefault')->extend('TableSort');
    $query->join('users', 'u', 'a.uid = u.uid');

    $query
      ->fields('a', array('aid', 'timestamp', 'url', 'uid'))
      ->fields('u', array('name'))
      ->condition(db_or()
        ->condition('a.path', 'node/' . $node->nid)
        ->condition('a.path', 'node/' . $node->nid . '/%', 'LIKE'))
      ->limit(30)
      ->orderByHeader($header);

    $result = $query->execute();
    $rows = array();
    foreach ($result as $log) {
      $rows[] = array(
        array('data' => format_date($log->timestamp, 'short'), 'class' => array('nowrap')),
        _statistics_link($log->url),
        theme('username', $log),
        l(t('details'), "admin/reports/access/$log->aid"),
      );
    }

    if (empty($rows)) {
      $rows[] = array(array('data' => t('No statistics available.'), 'colspan' => 4));
    }

    drupal_set_title($node->title);
    $build['statistics_table'] = array(
      '#theme' => 'table', 
      '#header' => $header, 
      '#rows' => $rows
    );
    $build['statistics_pager'] = array('#theme' => 'pager');
    return $build;
  }
  else {
    drupal_not_found();
  }
}

function statistics_user_tracker() {
  if ($account = user_load(arg(1))) {

    $header = array(
        array('data' => t('Timestamp'), 'field' => 'timestamp', 'sort' => 'desc'),
        array('data' => t('Page'), 'field' => 'path'),
        array('data' => t('Operations')));
    $query = db_select('accesslog', 'a')->extend('PagerDefault')->extend('TableSort');
    $query
      ->fields('a', array('aid', 'timestamp', 'path', 'title'))
      ->condition('uid', $account->uid)
      ->limit(30)
      ->orderByHeader($header);

    $result = $query->execute();
    $rows = array();
    foreach ($result as $log) {
      $rows[] = array(
        array('data' => format_date($log->timestamp, 'short'), 'class' => array('nowrap')),
        _statistics_format_item($log->title, $log->path),
        l(t('details'), "admin/reports/access/$log->aid"));
    }

    if (empty($rows)) {
      $rows[] = array(array('data' => t('No statistics available.'), 'colspan' => 3));
    }

    drupal_set_title($account->name);
    $build['statistics_table'] = array(
      '#theme' => 'table', 
      '#header' => $header, 
      '#rows' => $rows
    );
    $build['statistics_pager'] = array('#theme' => 'pager');
    return $build;
  }
  else {
    drupal_not_found();
  }
}
