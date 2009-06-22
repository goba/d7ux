<?php

/**
 * Theme a form button with <button> instead of <input>.
 */
function overlay_button($element) {
  // Make sure not to overwrite classes.
  $class = 'form-' . $element['#button_type'];
  if (strpos($element['#id'], 'submit')) {
    $class .= ' form-button-emphasized';
  }
  if (isset($element['#attributes']['class'])) {
    $element['#attributes']['class'] = $class . ' ' . $element['#attributes']['class'];
  }
  else {
    $element['#attributes']['class'] = $class;
  }

  return '<button type="submit" ' . (empty($element['#name']) ? '' : 'name="' . $element['#name'] . '" ') . 'id="' . $element['#id'] . '" value="' . check_plain($element['#value']) . '" ' . drupal_attributes($element['#attributes']) . "><span>" . check_plain($element['#value']) . "</span></button>\n";
}
