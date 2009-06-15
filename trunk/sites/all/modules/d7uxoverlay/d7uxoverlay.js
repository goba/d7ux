(function ($) {

Drupal.behaviors.d7uxOverlay = {
  attach: function(context) {
    
    // Attach on the .popups class, so we are
    // interchangeable with the popups module 
    // implementation for testing purposes.
    $('a.popups:not(.popups-processed)').addClass('popups-processed').click(function() {

      // Append d7uxmodalframe variable, so the server side can pick up
      // this marker and add child modal frame code to the page if needed.
      var linkURL = $(this).attr('href');
      linkURL += (linkURL.indexOf('?') > -1 ? '&' : '?') + 'd7uxmodalframe=1';
    
      // If the modal frame is already open, replace the loaded
      // document with this new one.
      if (Drupal.modalFrame.isOpen) {
        Drupal.modalFrame.load(linkURL);
        return false;
      }
    
      // There is no modal frame, we should open a new one.
      var headerHeight = $('#admin-toolbar').height();
      var modalOptions = {
        url: linkURL,
        autoResize: false,
        autoFit: false,
        width: $(window).width() - 40,
        height: $(window).height() - 40 - headerHeight
      };
      Drupal.modalFrame.open(modalOptions);
    
      // Set position and styling to let the admin header work.
      $('.modalframe').css('top', headerHeight + 20);
      $('#admin-toolbar').css('z-index', 2000);

      // Prevent default action of the link click event.
      return false;
    });
  }
};

})(jQuery);
