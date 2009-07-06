(function ($) {

Drupal.behaviors.d7uxOverlay = {
  attach: function(context) {
    
    // If on a node page, alter the Edit link with a link to
    // directly edit this node. 
    if (Drupal.settings.d7uxoverlay && Drupal.settings.d7uxoverlay.nodeEdit) {
      $('a#admin-link-admin-content-node-edit').attr('href', Drupal.settings.d7uxoverlay.nodeEdit);
    }
    
    // Attach on the .to-overlay class.
    $('a.to-overlay:not(.overlay-processed)').addClass('overlay-processed').click(function() {

      // Remove the active class from where it was, and add 
      // the active class to this link, so the button keeps 
      // highlighting where we are. 
      $('#toolbar a').each(function() { $(this).removeClass('active'); });
      $(this).addClass('active');
      
      // Append d7uxoverlay variable, so the server side can pick up
      // this marker and add child modal frame code to the page if needed.
      var linkURL = $(this).attr('href');
      linkURL += (linkURL.indexOf('?') > -1 ? '&' : '?') + 'd7uxoverlay=1';
    
      // If the modal frame is already open, replace the loaded
      // document with this new one.
      if (Drupal.overlay.isOpen) {
        Drupal.overlay.load(linkURL);
        return false;
      }
    
      // There is no modal frame, we should open a new one.
      var headerHeight = $('#toolbar').height();
      var modalOptions = {
        url: linkURL,
        autoResize: false,
        //autoFit: false,
        width: $(window).width() - 40,
        height: $(window).height() - 40 - headerHeight,
        // Remove active class from all header buttons.
        onSubmit: function() { $('#toolbar a').each(function() { $(this).removeClass('active'); }); }
      };
      Drupal.overlay.open(modalOptions);
    
      // Set position and styling to let the admin header work.
      $('.overlay').css('top', headerHeight + 20);
      $('#toolbar').css('z-index', 2000);

      // Prevent default action of the link click event.
      return false;
    });
  }
};

})(jQuery);
