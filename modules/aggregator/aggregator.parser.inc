<?php
// $Id: aggregator.parser.inc,v 1.4 2009/07/15 21:32:43 dries Exp $

/**
 * @file
 * Parser functions for the aggregator module.
 */

/**
 * Implement hook_aggregator_parse_info().
 */
function aggregator_aggregator_parse_info() {
  return array(
    'title' => t('Default parser'),
    'description' => t('Parses RSS, Atom and RDF feeds.'),
  );
}

/**
 * Implement hook_aggregator_parse().
 */
function aggregator_aggregator_parse($feed) {
  global $channel, $image;

  // Filter the input data.
  if (aggregator_parse_feed($feed->source_string, $feed)) {
    $modified = empty($feed->http_headers['Last-Modified']) ? 0 : strtotime($feed->http_headers['Last-Modified']);

    // Prepare the channel data.
    foreach ($channel as $key => $value) {
      $channel[$key] = trim($value);
    }

    // Prepare the image data (if any).
    foreach ($image as $key => $value) {
      $image[$key] = trim($value);
    }

    if (!empty($image['link']) && !empty($image['url']) && !empty($image['title'])) {
      $image = l(theme('image', $image['url'], $image['title']), $image['link'], array('html' => TRUE));
    }
    else {
      $image = '';
    }

    $etag = empty($feed->http_headers['ETag']) ? '' : $feed->http_headers['ETag'];
    // Update the feed data.
    db_merge('aggregator_feed')
      ->key(array('fid' => $feed->fid))
      ->fields(array(
        'url' => $feed->url,
        'checked' => REQUEST_TIME,
        'link' => !empty($channel['link']) ? $channel['link'] : '',
        'description' => !empty($channel['description']) ? $channel['description'] : '',
        'image' => $image,
        'hash' => md5($feed->source_string),
        'etag' => $etag,
        'modified' => $modified,
      ))
      ->execute();

    // Clear the cache.
    cache_clear_all();

    if (isset($feed->redirected)) {
      watchdog('aggregator', 'Updated URL for feed %title to %url.', array('%title' => $feed->title, '%url' => $feed->url));
    }

    watchdog('aggregator', 'There is new syndicated content from %site.', array('%site' => $feed->title));
    drupal_set_message(t('There is new syndicated content from %site.', array('%site' => $feed->title)));

  }
}

/**
 * Parse a feed and store its items.
 *
 * @param $data
 *   The feed data.
 * @param $feed
 *   An object describing the feed to be parsed.
 * @return
 *   FALSE on error, TRUE otherwise.
 */
function aggregator_parse_feed(&$data, $feed) {
  global $items, $image, $channel;

  // Unset the global variables before we use them.
  unset($GLOBALS['element'], $GLOBALS['item'], $GLOBALS['tag']);
  $items = array();
  $image = array();
  $channel = array();

  // Parse the data.
  $xml_parser = drupal_xml_parser_create($data);
  xml_set_element_handler($xml_parser, 'aggregator_element_start', 'aggregator_element_end');
  xml_set_character_data_handler($xml_parser, 'aggregator_element_data');

  if (!xml_parse($xml_parser, $data, 1)) {
    watchdog('aggregator', 'The feed from %site seems to be broken, due to an error "%error" on line %line.', array('%site' => $feed->title, '%error' => xml_error_string(xml_get_error_code($xml_parser)), '%line' => xml_get_current_line_number($xml_parser)), WATCHDOG_WARNING);
    drupal_set_message(t('The feed from %site seems to be broken, because of error "%error" on line %line.', array('%site' => $feed->title, '%error' => xml_error_string(xml_get_error_code($xml_parser)), '%line' => xml_get_current_line_number($xml_parser))), 'error');
    return FALSE;
  }
  xml_parser_free($xml_parser);

  // We reverse the array such that we store the first item last, and the last
  // item first. In the database, the newest item should be at the top.
  $items = array_reverse($items);

  // Initialize items array.
  $feed->items = array();
  foreach ($items as $item) {

    // Prepare the item:
    foreach ($item as $key => $value) {
      $item[$key] = trim($value);
    }

    // Resolve the item's title. If no title is found, we use up to 40
    // characters of the description ending at a word boundary, but not
    // splitting potential entities.
    if (!empty($item['title'])) {
      $item['title'] = $item['title'];
    }
    elseif (!empty($item['description'])) {
      $item['title'] = preg_replace('/^(.*)[^\w;&].*?$/', "\\1", truncate_utf8($item['description'], 40));
    }
    else {
      $item['title'] = '';
    }

    // Resolve the items link.
    if (!empty($item['link'])) {
      $item['link'] = $item['link'];
    }
    else {
      $item['link'] = $feed->link;
    }
    $item['guid'] = isset($item['guid']) ? $item['guid'] : '';

    // Atom feeds have a content and/or summary tag instead of a description tag.
    if (!empty($item['content:encoded'])) {
      $item['description'] = $item['content:encoded'];
    }
    elseif (!empty($item['summary'])) {
      $item['description'] = $item['summary'];
    }
    elseif (!empty($item['content'])) {
      $item['description'] = $item['content'];
    }

    // Try to resolve and parse the item's publication date.
    $date = '';
    foreach (array('pubdate', 'dc:date', 'dcterms:issued', 'dcterms:created', 'dcterms:modified', 'issued', 'created', 'modified', 'published', 'updated') as $key) {
      if (!empty($item[$key])) {
        $date = $item[$key];
        break;
      }
    }

    $item['timestamp'] = strtotime($date);

    if ($item['timestamp'] === FALSE) {
      $item['timestamp'] = aggregator_parse_w3cdtf($date); // Aggregator_parse_w3cdtf() returns FALSE on failure.
    }

    // Resolve dc:creator tag as the item author if author tag is not set.
    if (empty($item['author']) && !empty($item['dc:creator'])) {
      $item['author'] = $item['dc:creator'];
    }
     
    $item += array('author' => '', 'description' => '');

    // Store on $feed object. This is where processors will look for parsed items.
    $feed->items[] = $item;
  }

  return TRUE;
}

/**
 * Callback function used by the XML parser.
 */
function aggregator_element_start($parser, $name, $attributes) {
  global $item, $element, $tag, $items, $channel;

  $name = strtolower($name);
  switch ($name) {
    case 'image':
    case 'textinput':
    case 'content':
    case 'summary':
    case 'tagline':
    case 'subtitle':
    case 'logo':
    case 'info':
      $element = $name;
      break;
    case 'id':
      if ($element != 'item') {
        $element = $name;
      }
    case 'link':
      if (!empty($attributes['rel']) && $attributes['rel'] == 'alternate') {
        if ($element == 'item') {
          $items[$item]['link'] = $attributes['href'];
        }
        else {
          $channel['link'] = $attributes['href'];
        }
      }
      break;
    case 'item':
      $element = $name;
      $item += 1;
      break;
    case 'entry':
      $element = 'item';
      $item += 1;
      break;
  }

  $tag = $name;
}

/**
 * Call-back function used by the XML parser.
 */
function aggregator_element_end($parser, $name) {
  global $element;

  switch ($name) {
    case 'image':
    case 'textinput':
    case 'item':
    case 'entry':
    case 'content':
    case 'info':
      $element = '';
      break;
    case 'id':
      if ($element == 'id') {
        $element = '';
      }
  }
}

/**
 * Callback function used by the XML parser.
 */
function aggregator_element_data($parser, $data) {
  global $channel, $element, $items, $item, $image, $tag;
  $items += array($item => array());
  switch ($element) {
    case 'item':
      $items[$item] += array($tag => '');
      $items[$item][$tag] .= $data;
      break;
    case 'image':
    case 'logo':
      $image += array($tag => '');
      $image[$tag] .= $data;
      break;
    case 'link':
      if ($data) {
        $items[$item] += array($tag => '');
        $items[$item][$tag] .= $data;
      }
      break;
    case 'content':
      $items[$item] += array('content' => '');
      $items[$item]['content'] .= $data;
      break;
    case 'summary':
      $items[$item] += array('summary' => '');
      $items[$item]['summary'] .= $data;
      break;
    case 'tagline':
    case 'subtitle':
      $channel += array('description' => '');
      $channel['description'] .= $data;
      break;
    case 'info':
    case 'id':
    case 'textinput':
      // The sub-element is not supported. However, we must recognize
      // it or its contents will end up in the item array.
      break;
    default:
      $channel += array($tag => '');
      $channel[$tag] .= $data;
  }
}

/**
 * Parse the W3C date/time format, a subset of ISO 8601.
 *
 * PHP date parsing functions do not handle this format.
 * See http://www.w3.org/TR/NOTE-datetime for more information.
 * Originally from MagpieRSS (http://magpierss.sourceforge.net/).
 *
 * @param $date_str
 *   A string with a potentially W3C DTF date.
 * @return
 *   A timestamp if parsed successfully or FALSE if not.
 */
function aggregator_parse_w3cdtf($date_str) {
  if (preg_match('/(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})(:(\d{2}))?(?:([-+])(\d{2}):?(\d{2})|(Z))?/', $date_str, $match)) {
    list($year, $month, $day, $hours, $minutes, $seconds) = array($match[1], $match[2], $match[3], $match[4], $match[5], $match[6]);
    // Calculate the epoch for current date assuming GMT.
    $epoch = gmmktime($hours, $minutes, $seconds, $month, $day, $year);
    if ($match[10] != 'Z') { // Z is zulu time, aka GMT
      list($tz_mod, $tz_hour, $tz_min) = array($match[8], $match[9], $match[10]);
      // Zero out the variables.
      if (!$tz_hour) {
        $tz_hour = 0;
      }
      if (!$tz_min) {
        $tz_min = 0;
      }
      $offset_secs = (($tz_hour * 60) + $tz_min) * 60;
      // Is timezone ahead of GMT?  If yes, subtract offset.
      if ($tz_mod == '+') {
        $offset_secs *= -1;
      }
      $epoch += $offset_secs;
    }
    return $epoch;
  }
  else {
    return FALSE;
  }
}
