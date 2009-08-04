// $Id$
(function ($) {

/**
 * Highlights the actions region when hovering over an edit link.
 */
Drupal.behaviors.highlightEditableRegion = {
  attach: function (context) {
    var addHighlight = function () {
      var matches = $(this).attr('class').match(/[^ ]*-at-(\S+)/);
      if (matches) {
        var class = '.actions-enabled-at-' + matches[1];
        $(class).addClass('active-actions-region');
        $(this).addClass('active-actions-link');
      }
    };

    var removeHighlight = function () {
      $('.active-actions-region').removeClass('active-actions-region');
      $('.active-actions-link').removeClass('active-actions-link');
    };

    $('.action-links li').hover(addHighlight, removeHighlight);
  }
};

})(jQuery);
