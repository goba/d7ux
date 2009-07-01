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

    // Toggling of admin shortcuts visibility.
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
 * Initialize cautiously to avoid collisions with other modules (admin_menu).
 */
Drupal.admin = Drupal.admin || {};
Drupal.admin.toolbar = Drupal.admin.toolbar || {};

/**
 * Retrieve last saved cookie settings and set up the initial toolbar state.
 */
Drupal.admin.toolbar.init = function() {
  // Retrieve the collapsed status from a stored cookie.
  var collapsed = $.cookies.get('Drupal.admin.toolbar.collapsed');

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
  $('#admin-toolbar div.admin-shortcuts').addClass('collapsed');
  $('#admin-toolbar span.toggle').removeClass('toggle-active');
  $('body').removeClass('admin-toolbar-shortcuts');
  $.cookies.set(
    'Drupal.admin.toolbar.collapsed', 
    1, 
    {path: Drupal.settings.basePath}
  );
}

/**
 * Expand the admin toolbar.
 */
Drupal.admin.toolbar.expand = function() {
  $('#admin-toolbar div.admin-shortcuts').removeClass('collapsed');
  $('#admin-toolbar span.toggle').addClass('toggle-active');
  $('body').addClass('admin-toolbar-shortcuts');
  $.cookies.set(
    'Drupal.admin.toolbar.collapsed', 
    0, 
    {path: Drupal.settings.basePath}
  );
}

/**
 * Toggle the admin toolbar.
 */
Drupal.admin.toolbar.toggle = function() {
  if ($('#admin-toolbar div.admin-shortcuts').is('.collapsed')) {
    Drupal.admin.toolbar.expand();
  }
  else {
    Drupal.admin.toolbar.collapse();
  }
}

})(jQuery);
