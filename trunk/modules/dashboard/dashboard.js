// $Id: toolbar.js,v 1.1 2009/07/04 05:37:30 dries Exp $
(function ($) {

/**
 * Implementation of Drupal.behaviors for dashboard.
 */
Drupal.behaviors.dashboard = {
  attach: function () {
    $('#dashboard').prepend('<div class="customize"><ul class="action-links"><a href="#">' + Drupal.t('Customize') + '</a></ul><div class="canvas"></div></div>');
    $('#dashboard .customize .action-links a').click(Drupal.behaviors.dashboard.enterCustomizeMode);
  },

  /**
   * Enter "customize" mode by displaying disabled blocks.
   */
  enterCustomizeMode: function () {
    $('#dashboard .customize .action-links').hide();
    $('div.customize .canvas').load(Drupal.settings.dashboard.customize, Drupal.behaviors.dashboard.setupDrawer);
  },

  /**
   * Exit "customize" mode by simply forcing a page refresh.
   */
  exitCustomizeMode: function () {
    location.reload();
  },

  /**
   * Helper for enterCustomizeMode; sets up drag-and-drop and close button.
   */
  setupDrawer: function () {
    $('div.customize .canvas-content').prepend('<input type="button" class="form-submit" value="' + Drupal.t('Done') + '"></input>');
    $('div.customize .canvas-content input').click(Drupal.behaviors.dashboard.exitCustomizeMode);

    // Initialize drag-and-drop.
    var regions = $('div.region');
    regions.sortable({
      connectWith: regions,
      cursor: 'move',
      cursorAt: 'left',
      dropOnEmpty: true,
      items: '>div.block, div.disabled-block',
      opacity: 0.8,
      helper: 'block-dragging',
      placeholder: 'block-placeholder clearfix',
      start: Drupal.behaviors.dashboard.start,
      update: Drupal.behaviors.dashboard.update
    });
  },

  /**
   * While dragging, make the block appear as a disabled block
   *
   * This function is called on the jQuery UI Sortable "start" event.
   *
   * @param event
   *  The event that triggered this callback.
   * @param ui
   *  An object containing information about the item that is being dragged.
   */
  start: function (event, ui) {
    var item = $(ui.item);

    // If the block is already in disabled state, don't do anything.
    if (!item.hasClass('disabled-block')) {
      item.css({height: 'auto'});
    }
  },

  /**
   * Send block order to the server, and expand previously disabled blocks.
   *
   * This function is called on the jQuery UI Sortable "update" event.
   *
   * @param event
   *   The event that triggered this callback.
   * @param ui
   *   An object containing information about the item that was just dropped.
   */
  update: function (event, ui) {
    var item = $(ui.item);

    // If the user dragged a disabled block, load the block contents.
    if (item.hasClass('disabled-block')) {
      var module, delta, itemClass;
      itemClass = item.attr('class');
      // Determine the block module and delta.
      module = itemClass.match(/\bmodule-(\S+)\b/)[1];
      delta = itemClass.match(/\bdelta-(\S+)\b/)[1];

      // Load the newly enabled block's content.
      $.get(Drupal.settings.dashboard.blockContent + '/' + module + '/' + delta, {},
        function (block) {
          var blockContent = $("div.content", $(block));
          $("div.content", item).after(blockContent).remove();
        },
        'html'
      );
      // Remove the "disabled-block" class, so we don't reload its content the
      // next time it's dragged.
      item.removeClass("disabled-block");
    }

    // Let the server know what the new block order is.
    $.post(Drupal.settings.dashboard.updatePath, {
        'form_token': Drupal.settings.dashboard.formToken,
        'regions': Drupal.behaviors.dashboard.getOrder
      }
    );
  },

  /**
   * Return the current order of the blocks in each of the sortable regions,
   * in query string format.
   */
  getOrder: function () {
    var order = [];
    $('div.region').each(function () {
      var region = $(this).parent().attr('id').replace(/-/g, '_');
      var blocks = $(this).sortable('toArray');
      var i;
      for (i = 0; i < blocks.length; i++) {
        order.push(region + '[]=' + blocks[i]);
      }
    });
    order = order.join('&');
    return order;
  }
};

})(jQuery);
