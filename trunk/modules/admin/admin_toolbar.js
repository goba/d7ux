// $Id$
(function ($) {

/**
 * Implementation of Drupal.behaviors for admin.
 */
Drupal.behaviors.admin = {
  attach: function() {
    // Set the intial state of the toolbar
    $('#admin-toolbar:not(.processed)').each(function() {
      Drupal.admin.toolbar.init();
      $(this).addClass('processed');
    });
    // Toggling of admin link visibility.
    $('#admin-toolbar span.toggle:not(.processed)').each(function() {
      $(this).click(function() {
        Drupal.admin.toolbar.toggle();
        return false;
      });
      $(this).addClass('processed');
    });
  }
};

/**
 * Initialize the admin object cautiously to avoid collisions with other
 * modules (admin_menu).
 */
Drupal.admin = Drupal.admin || {};
Drupal.admin.toolbar = Drupal.admin.toolbar || {};

/**
 * Retrieve last saved cookie settings and set up the initial toolbar state.
 */
Drupal.admin.toolbar.init = function() {
  // Retrieve the collapsed status from a stored cookie.
  var collapsed = null;
  var name = 'Drupal.admin.toolbar.collapsed';
  if (document.cookie && document.cookie != '') {
    var cookies = document.cookie.split(';');
    for (var i = 0; i < cookies.length; i++) {
      var cookie = jQuery.trim(cookies[i]);
      // Does this cookie string begin with the name we want?
      if (cookie.substring(0, name.length + 1) == (name + '=')) {
        collapsed = decodeURIComponent(cookie.substring(name.length + 1));
        break;
      }
    }
  }

  // Expand or collapse the toolbar based on the cookie value.
  if (collapsed == 1) {
    Drupal.admin.toolbar.collapse();
  }
  else {
    Drupal.admin.toolbar.expand();
  }
}

/**
 * Collapse the admin toolbar.
 */
Drupal.admin.toolbar.collapse = function() {
  $('#admin-toolbar div.admin-links').addClass('collapsed');
  $('#admin-toolbar span.toggle').removeClass('toggle-active');
  $('body').removeClass('admin-toolbar-links');

  document.cookie = ['Drupal.admin.toolbar.collapsed', '=', encodeURIComponent(1), '; expires=-1', '; path='+ Drupal.settings.basePath].join('');
}

/**
 * Expand the admin toolbar.
 */
Drupal.admin.toolbar.expand = function() {
  $('#admin-toolbar div.admin-links').removeClass('collapsed');
  $('#admin-toolbar span.toggle').addClass('toggle-active');
  $('body').addClass('admin-toolbar-links');

  document.cookie = ['Drupal.admin.toolbar.collapsed', '=', encodeURIComponent(0), '; expires=-1', '; path='+ Drupal.settings.basePath].join('');
}

/**
 * Toggle the admin toolbar.
 */
Drupal.admin.toolbar.toggle = function() {
  if ($('#admin-toolbar div.admin-links').is('.collapsed')) {
    Drupal.admin.toolbar.expand();
  }
  else {
    Drupal.admin.toolbar.collapse();
  }
}

})(jQuery);
