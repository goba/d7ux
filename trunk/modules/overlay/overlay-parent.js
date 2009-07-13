// $Id: parent.js,v 1.1.4.4 2009/06/19 15:32:57 markuspetrux Exp $

(function ($) {

Drupal.behaviors.keepOverlay = {
  attach: function(context) {

    // Attach on the .to-overlay class.
    $('a.to-overlay:not(.overlay-processed)').addClass('overlay-processed').click(function() {

      // Remove the active class from where it was, and add the active class to
      // this link, so the button keeps highlighting where we are. Only
      // highlight active items in the shortcuts bar.
      $('#toolbar a').each(function() {
        $(this).removeClass('active');
      });
      if ($(this).parents('div.toolbar-shortcuts').length) {
        $(this).addClass('active');
      }

      // Append render variable, so the server side can choose the right
      // rendering and add child modal frame code to the page if needed.
      var linkURL = $(this).attr('href');
      linkURL += (linkURL.indexOf('?') > -1 ? '&' : '?') + 'render=overlay';

      // If the modal frame is already open, replace the loaded document with
      // this new one. Keeps browser history.
      if (Drupal.overlay.isOpen) {
        Drupal.overlay.load(linkURL);
        return false;
      }

      // There is overlay opened yet, we should open a new one.
      var toolbarHeight = $('#toolbar').height();
      var overlayOptions = {
        url: linkURL,
        width: $(window).width() - 40,
        height: $(window).height() - 40 - toolbarHeight,
        // Remove active class from all header buttons.
        onOverlayClose: function() { $('#toolbar a').each(function() { $(this).removeClass('active'); }); }
      };
      Drupal.overlay.open(overlayOptions);

      // Set position and styling to let the admin toolbar work.
      $('.overlay').css('top', toolbarHeight + 20);
      $('#toolbar').css('z-index', 2000);

      // Prevent default action of the link click event.
      return false;
    });
  }
};

/**
 * Overlay object for parent windows.
 */
Drupal.overlay = Drupal.overlay || {
  options: {},
  iframe: { $container: null, $element: null },
  isOpen: false
};

/**
 * Open an overlay.
 */
Drupal.overlay.open = function(options) {
  var self = this;

  // Just one overlay is allowed.
  if (self.isOpen || $('#overlay-container').size()) {
    return false;
  }

  // Build overlay frame options structure.
  self.options = {
    url: options.url,
    width: options.width,
    height: options.height,
    autoFit: (options.autoFit == undefined || options.autoFit),
    onOverlayClose: options.onOverlayClose
  };

  // Create the dialog and related DOM elements.
  self.create(options);

  // Open the dialog offscreen where we can set its size, etc.
  self.iframe.$container.dialog('option', {position: ['-999em', '-999em']}).dialog('open');

  return true;
};

/**
 * Create the overlay.
 */
Drupal.overlay.create = function() {
  var self = this;

  // Note: We use scrolling="yes" for IE as a workaround to yet another IE bug
  // where the horizontal scrollbar is always rendered no matter how wide the
  // iframe element is defined.
  self.iframe.$element = $('<iframe id="overlay-element" frameborder="0" name="overlay-element"'+ ($.browser.msie ? ' scrolling="yes"' : '') +'/>');
  self.iframe.$container = $('<div id="overlay-container"/>').append(self.iframe.$element);
  self.iframe.$element
    .after($('<div class="overlay-shadow overlay-shadow-right" />').append('<div class="overlay-shadow overlay-shadow-bottom-right" />'))
    .after($('<div class="overlay-shadow overlay-shadow-bottom" />').append('<div class="overlay-shadow overlay-shadow-bottom-left" />'));

  $('body').append(self.iframe.$container);

  self.iframe.$container.dialog({
    modal: true,
    autoOpen: false,
    closeOnEscape: true,
    resizable: false,
    title: Drupal.t('Loading...'),
    dialogClass: 'overlay',
    open: function() {
      // Unbind the keypress handler installed by ui.dialog itself.
      // IE does not fire keypress events for some non-alphanumeric keys
      // such as the tab character. http://www.quirksmode.org/js/keys.html
      // Also, this is not necessary here because we need to deal with an
      // iframe element that contains a separate window.
      // We'll try to provide our own behavior from bindChild() method.
      $('.overlay').unbind('keypress.ui-dialog');

      // Adjust close button features.
      $('.overlay .ui-dialog-titlebar-close:not(.overlay-processed)').addClass('overlay-processed')
        .attr('href', 'javascript:void(0)')
        .attr('title', Drupal.t('Close'))
        .unbind('click')
        .bind('click', function() { try { self.close(false); } catch(e) {}; return false; })
        .before('<div class="ui-dialog-titlebar-close-bg" />');

      // Compute initial dialog size.
      var dialogSize = self.sanitizeSize({width: self.options.width, height: self.options.height});

      // Compute frame size and dialog position based on dialog size.
      var frameSize = $.extend({}, dialogSize);
      frameSize.height -= $('.overlay .ui-dialog-titlebar').outerHeight(true);
      var dialogPosition = self.computePosition($('.overlay'), dialogSize);

      // Adjust size of the iframe element and container.
      $('.overlay').width(dialogSize.width).height(dialogSize.height);
      self.iframe.$container.width(frameSize.width).height(frameSize.height);
      self.iframe.$element.width(frameSize.width).height(frameSize.height);

      // Update the dialog size so that UI internals are aware of the change.
      self.iframe.$container.dialog('option', {width: dialogSize.width, height: dialogSize.height});

      // Hide the dialog, position it on the viewport and then fade it in with
      // the frame hidden until the child document is loaded.
      self.iframe.$element.hide();
      $('.overlay').hide().css({top: dialogPosition.top, left: dialogPosition.left});
      $('.overlay').fadeIn('fast', function() {
        // Load the document on hidden iframe (see bindChild method).
        self.load(self.options.url);
      });

      self.isOpen = true;
    },
    beforeclose: function() {
      if (self.beforeCloseEnabled) {
        return true;
      }
      if (!self.beforeCloseIsBusy) {
        self.beforeCloseIsBusy = true;
        setTimeout(function() { self.close(false); }, 1);
      }
      return false;
    },
    close: function() {
      $(document).unbind('keydown.overlay-event');
      $('.overlay .ui-dialog-titlebar-close').unbind('keydown.overlay-event');
      try {
        self.iframe.$element.remove();
        self.iframe.$container.dialog('destroy').remove();
      } catch(e) {};
      delete self.iframe.documentSize;
      delete self.iframe.Drupal;
      delete self.iframe.$element;
      delete self.iframe.$container;
      if (self.beforeCloseEnabled) {
        delete self.beforeCloseEnabled;
      }
      if (self.beforeCloseIsBusy) {
        delete self.beforeCloseIsBusy;
      }
      self.isOpen = false;
    }
  });
};

/**
 * Load the given URL into the dialog iframe.
 */
Drupal.overlay.load = function(url) {
  var self = this;
  var iframe = self.iframe.$element.get(0);
  // Get the document object of the iframe window.
  // @see http://xkr.us/articles/dom/iframe-document/
  var doc = (iframe.contentWindow || iframe.contentDocument);
  if (doc.document) {
    doc = doc.document;
  }
  doc.location.replace(url);
};

/**
 * Check if the dialog can be closed.
 */
Drupal.overlay.canClose = function() {
  var self = this;
  if (!self.isOpen) {
    return false;
  }
  return true;
};

/**
 * Close the overlay.
 */
Drupal.overlay.close = function(args, statusMessages) {
  var self = this;

  // Check if the dialog can be closed.
  if (!self.canClose()) {
    delete self.beforeCloseIsBusy;
    return false;
  }

  // Hide and destroy the dialog.
  function closeDialog() {
    // Prevent double execution when close is requested more than once.
    if (!self.isObject(self.iframe.$container)) {
      return;
    }
    self.beforeCloseEnabled = true;
    self.iframe.$container.dialog('close');
    if ($.isFunction(self.options.onOverlayClose)) {
      self.options.onOverlayClose(args, statusMessages);
    }
  }
  if (!self.isObject(self.iframe.$element) || !self.iframe.$element.size() || !self.iframe.$element.is(':visible')) {
    closeDialog();
  }
  else {
    self.iframe.$element.fadeOut('fast', function() {
      $('.overlay').animate({height: 'hide', opacity: 'hide'}, closeDialog);
    });
  }
  return true;
};

/**
 * Bind the child window.
 */
Drupal.overlay.bindChild = function(iFrameWindow, isClosing) {
  var self = this;
  var $iFrameWindow = iFrameWindow.jQuery;
  var $iFrameDocument = $iFrameWindow(iFrameWindow.document);
  self.iframe.Drupal = iFrameWindow.Drupal;

  // We are done if the child window is closing.
  if (isClosing) {
    return;
  }

  // Update the dialog title with the child window title.
  $('.overlay .ui-dialog-title').html($iFrameDocument.attr('title'));

  // Remove any existing tabs.
  $('.overlay .ui-dialog-titlebar ul').remove();

  // Setting tabIndex makes the div focusable.
  // Setting outline to 0 prevents a border on focus in Mozilla.
  // Inspired by ui.dialog initialization code.
  $iFrameDocument.attr('tabIndex', -1).css('outline', 0);

  $('.ui-dialog-titlebar-close-bg').animate({opacity: 1}, 'fast');

  // Perform animation to show the iframe element.
  self.iframe.$element.fadeIn('fast', function() {
    // @todo: Watch for experience in the way we compute the size of the
    // iframed document. There are many ways to do it, and none of them
    // seem to be perfect. Note though, that the size of the iframe itself
    // may affect the size of the child document, specially on fluid layouts.
    // If you get in trouble, then I would suggest to choose a known dialog
    // size and disable the option autoFit.
    self.iframe.documentSize = {width: $iFrameDocument.width(), height: $iFrameWindow('body').height() + 25 };

    // Adjust overlay to fit the iframe content?
    if (self.options.autoFit) {
      self.resize(self.iframe.documentSize);
    }

    // Try to enhance keyboard based navigation of the overlay.
    // Logic inspired by the open() method in ui.dialog.js, and
    // http://wiki.codetalks.org/wiki/index.php/Docs/Keyboard_navigable_JS_widgets

    // Get a reference to the close button.
    var $closeButton = $('.overlay .ui-dialog-titlebar-close');

    // Search tabbable elements on the iframed document to speed up related
    // keyboard events.
    // @todo: Do we need to provide a method to update these references when
    // AJAX requests update the DOM on the child document?
    var $iFrameTabbables = $iFrameWindow(':tabbable:not(form)');
    var $firstTabbable = $iFrameTabbables.filter(':first');
    var $lastTabbable = $iFrameTabbables.filter(':last');

    // Set focus to the first tabbable element in the content area or the
    // first button. If there are no tabbable elements, set focus on the
    // close button of the dialog itself.
    if (!$firstTabbable.focus().size()) {
      $iFrameDocument.focus();
    }

    // Unbind keyboard event handlers that may have been enabled previously.
    $(document).unbind('keydown.overlay-event');
    $closeButton.unbind('keydown.overlay-event');

    // When the focus leaves the close button, then we want to jump to the
    // first/last inner tabbable element of the child window.
    $closeButton.bind('keydown.overlay-event', function(event) {
      if (event.keyCode && event.keyCode == $.ui.keyCode.TAB) {
        var $target = (event.shiftKey ? $lastTabbable : $firstTabbable);
        if (!$target.size()) {
          $target = $iFrameDocument;
        }
        setTimeout(function() { $target.focus(); }, 10);
        return false;
      }
    });

    // When the focus leaves the child window, then drive the focus to the
    // close button of the dialog.
    $iFrameDocument.bind('keydown.overlay-event', function(event) {
      if (event.keyCode) {
        if (event.keyCode == $.ui.keyCode.TAB) {
          if (event.shiftKey && event.target == $firstTabbable.get(0)) {
            setTimeout(function() { $closeButton.focus(); }, 10);
            return false;
          }
          else if (!event.shiftKey && event.target == $lastTabbable.get(0)) {
            setTimeout(function() { $closeButton.focus(); }, 10);
            return false;
          }
        }
        else if (event.keyCode == $.ui.keyCode.ESCAPE) {
          setTimeout(function() { self.close(false); }, 10);
          return false;
        }
      }
    });

    // When the focus is captured by the parent document, then try
    // to drive the focus back to the first tabbable element, or the
    // close button of the dialog (default).
    $(document).bind('keydown.overlay-event', function(event) {
      if (event.keyCode && event.keyCode == $.ui.keyCode.TAB) {
        setTimeout(function() {
          if (!$iFrameWindow(':tabbable:not(form):first').focus().size()) {
            $closeButton.focus();
          }
        }, 10);
        return false;
      }
    });

    var tabs = $iFrameDocument.find('ul.horizontal-tabs-panes, ul.primary').get(0);

    // If there are tabs in the page, move them to the titlebar.
    if (typeof tabs != 'undefined') {
      $('.ui-dialog-titlebar').append($(tabs).remove().get(0));
      if ($(tabs).is('.primary')) {
        $(tabs).find('a').addClass('to-overlay').removeClass('overlay-processed');
        Drupal.attachBehaviors($(tabs));
      }
      // Remove any classes from the list element to avoid theme styles
      // clashing with our styling.
      $(tabs).removeAttr('class');
    }
  });
};

/**
 * Unbind the child window.
 */
Drupal.overlay.unbindChild = function(iFrameWindow) {
  var self = this;

  // Prevent memory leaks by explicitly unbinding keyboard event handler
  // on the child document.
  iFrameWindow.jQuery(iFrameWindow.document).unbind('keydown.overlay-event');

  // Change the overlay title.
  $('.overlay .ui-dialog-title').html(Drupal.t('Please, wait...'));

  // Hide the iframe element.
  self.iframe.$element.fadeOut('fast');
};

/**
 * Check if the given variable is an object.
 */
Drupal.overlay.isObject = function(something) {
  return (something !== null && typeof something === 'object');
};

/**
 * Sanitize dialog size.
 */
Drupal.overlay.sanitizeSize = function(size) {
  var width, height;
  var $window = $(window);
  var minWidth = 300, maxWidth = parseInt($window.width() * .92);
  if (typeof size.width != 'number') {
    width = maxWidth;
  }
  else if (size.width < minWidth || size.width > maxWidth) {
    width = Math.min(maxWidth, Math.max(minWidth, size.width));
  }
  else {
    width = size.width;
  }
  var minHeight = 100, maxHeight = parseInt($window.height() * .92);
  if (typeof size.height != 'number') {
    height = maxHeight;
  }
  else if (size.height < minHeight) {
    // Do not consider maxHeight, only set up to be at least the minimal height.
    height = Math.max(minHeight, size.height);
  }
  else {
    height = size.height;
  }
  return {width: width, height: height};
};

/**
 * Compute position to center horizontally and on viewport top vertically.
 */
Drupal.overlay.computePosition = function($element, elementSize) {
  var $window = $(window);
  // Consider the possibly displayed admin toolbar.
  var $toolbar = $('#toolbar');
  var toolbarHeight = $toolbar ? $toolbar.height() : 0;
  var position = {
    left: Math.max(0, parseInt(($window.width() - elementSize.width) / 2)),
    top: toolbarHeight + 20
  };
  // @todo: this helps when the toolbar moves with the page, since otherwise
  // we might open a screen which does not show on the viewport. It is not
  // nice however, when one scrolls up top again and the overlay is not there.
  if ($element.css('position') != 'fixed') {
    var $document = $(document);
    position.left += $document.scrollLeft();
    position.top += $document.scrollTop();
  }
  return position;
};

/**
 * Resize overlay.
 */
Drupal.overlay.resize = function(size) {
  var self = this;

  // Compute frame and dialog size based on requested document size.
  var titleBarHeight = $('.overlay .ui-dialog-titlebar').outerHeight(true);
  var frameSize = self.sanitizeSize(size); 
  var dialogSize = $.extend({}, frameSize);
  dialogSize.height += titleBarHeight + 15;

  // Compute position on viewport.
  var dialogPosition = self.computePosition($('.overlay'), dialogSize);

  var animationOptions = $.extend(dialogSize, dialogPosition);

  // Perform the resize animation.
  $('.overlay').animate(animationOptions, 'fast', function() {
    // Proceed only if the dialog still exists.
    if (self.isObject(self.iframe.$element) && self.isObject(self.iframe.$container)) {
      // Resize the iframe element and container.
      $('.overlay').width(dialogSize.width).height(dialogSize.height);
      self.iframe.$container.width(frameSize.width).height(frameSize.height);
      self.iframe.$element.width(frameSize.width).height(frameSize.height);
      $('.overlay-shadow-right').height(frameSize.height);
      
      // Animate shadows and the close button
      $('.overlay-shadow', $(this)).animate({opacity:1}, 'slow');

      // Update the dialog size so that UI internals are aware of the change.
      self.iframe.$container.dialog('option', {width: dialogSize.width, height: dialogSize.height});

      // Keep the dim background grow or shrink with the dialog.
      $('.ui-widget-overlay').height($(document).height());
      
      // Animate body opacity, so we fade in the page page as it loads in. 
      $(self.iframe.$element.get(0)).contents().find('body.overlay').animate({opacity:1}, 'slow');
    }
  });
};

})(jQuery);
