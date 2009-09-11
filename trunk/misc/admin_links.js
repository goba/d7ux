// $Id$
(function ($) {

/**
 * Highlights the admin links region when hovering over an edit link.
 */
Drupal.behaviors.highlightEditableRegion = {
  attach: function (context) {
    var addHighlight = function () {
      var matches = $(this).attr('class').match(/[^ ]*-at-(\S+)/);
      if (matches) {
        var class = '.admin-links-enabled-at-' + matches[1];
        $(class).addClass('active-admin-links-region');
        $(this).addClass('active-admin-links-link');
      }
    };

    var removeHighlight = function () {
      $('.active-admin-links-region').removeClass('active-admin-links-region');
      $('.active-admin-links-link').removeClass('active-admin-links-link');
    };

    $('.admin-links-link').hover(addHighlight, removeHighlight);
  }
};

})(jQuery);