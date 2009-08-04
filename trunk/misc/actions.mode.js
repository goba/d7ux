// $Id$
(function ($) {

/**
 * Allows any actions region on the page to be clicked on and edited.
 */
Drupal.behaviors.enableEditMode = {
  attach: function (context) {
    /**
     * Show the action link within an actions region, and highlight the region.
     */
    var showEditable = function () {
      hideEditable(); // Doesn't quite work right.
      $(this).addClass('active-actions-region');
      var matches = $(this).attr('class').match(/actions-enabled-at-(\S+)/g);
      if (matches) {
        for (i in matches) {
          var actionClass = '.actions-at-' + matches[i].replace(/actions-enabled-at-/, '');
          $(actionClass).show();
          $(actionClass).addClass('active-actions-link');
        }
      }
    };

    /**
     * Hide the action link within an actions region, and remove highlighting.
     */
    var hideEditable = function () {
      $('.active-actions-region').removeClass('active-actions-region');
      $('.active-actions-link').hide();
      $('.active-actions-link').removeClass('active-actions-link');
    };

    // Hide all action links.
    $('.actions-link').hide();

    // Highlight the actions region.
    $('.actions-enabled-region').hover(showEditable, hideEditable);
  }
};

})(jQuery);
