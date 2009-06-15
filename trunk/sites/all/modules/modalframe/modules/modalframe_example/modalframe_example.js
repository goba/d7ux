// $Id: modalframe_example.js,v 1.1.2.3 2009/05/29 16:32:35 markuspetrux Exp $

(function ($) {

Drupal.behaviors.modalFrameExample = {
  attach: function(context) {
  $('.modalframe-example-child:not(.modalframe-example-processed)').addClass('modalframe-example-processed').click(function() {
    var element = this;

    // This is our onSubmit callback that will be called from the child window
    // when it is requested by a call to modalframe_close_dialog() performed
    // from server-side submit handlers.
    function onSubmitCallbackExample(args) {
      if (args && args.message) {
        // Provide a simple feedback alert deferred a little.
        setTimeout(function() { alert(args.message); }, 500);
      }
    }

    // Build modal frame options.
    var modalOptions = {
      url: $(element).attr('href'),
      autoResize: true,
      onSubmit: onSubmitCallbackExample
    };

    // Try to obtain the dialog size from the className of the element.
    var regExp = /^.*modalframe-example-size\[\s*([0-9]*\s*,\s*[0-9]*)\s*\].*$/;
    if (typeof element.className == 'string' && regExp.test(element.className)) {
      var size = element.className.replace(regExp, '$1').split(',');
      modalOptions.width = parseInt(size[0].replace(/ /g, ''));
      modalOptions.height = parseInt(size[1].replace(/ /g, ''));
    }

    // Open the modal frame dialog.
    Drupal.modalFrame.open(modalOptions);

    // Prevent default action of the link click event.
    return false;
  });
  }
};

})(jQuery);