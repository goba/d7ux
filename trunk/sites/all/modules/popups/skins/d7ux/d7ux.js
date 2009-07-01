(function ($) {

/**
 * Theme the popup, so the close button is displayed at the right place.
 */
Drupal.theme.popupTemplate = function(popupId) {
  var template;
  template += '<div id="'+ popupId + '" class="popups-box">';
  template += '  <div class="popups-container">';
  template += '    <div class="popups-title">%title</div>';
  template += '    <div class="popups-close"><a href="#"><img src="' + Popups.originalSettings.basePath + Popups.originalSettings.popups.modulePath + '/skins/d7ux/close.png" alt="X"></a></div>';
  template += '    <div class="popups-body">';
  template += '      %body';
  template += '    </div>';
  template += '    <div class="popups-buttons">%buttons</div>';
  template += '    <div class="popups-footer"></div>';
  template += '  </div>';
  template += '</div>';
  return template;
};

/**
 * We need to resize the popups-container as well as the popups if it scrolls
 */
Drupal.behaviors.d7uxOverlay = {
  attach: function(context) {
    var popup = Popups.activePopup();
    if (popup) {
      var $popup = popup.$popup();
      var popupWidth = $popup.width();
      var windowWidth = Popups.windowWidth();
      var headerHeight = $('#toolbar').height();
      var windowHeight = Popups.windowHeight();
      var titleHeight = $('#' + popup.id + ' .popups-title').height();

      // Need to resize the popups container so we can accomodate for the larger overlay.
      $popup.height(windowHeight - headerHeight - 60);
      // Since the container will not resize the body, which gives the background, we
      // need to resize the body. The body is topped with the overlay title and has a 15px
      // padding, so 90 would be more accurate, but it might not fly depending on how pixel
      // perfect a browser is, so we use 95px here.
      $('#' + popup.id + ' .popups-body').height(windowHeight - headerHeight - titleHeight - 95);
      // Set window width to as wide as possible.
      $popup.width(windowWidth - 56);
      // Position the overlay 20px below the header, 30 from the left.
      $popup.css('top', headerHeight + 20).css('left', 30);
    
      // Add popups class to all links in the newly added popup.
      $('#' + popup.id + ' a:not(.popups)').addClass('popups');
    }
  }
};


})(jQuery);