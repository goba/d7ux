// $Id$

(function ($) {

/**
 * This script sorts a set of elements into a set of horizontal tabs. Another
 * tab pane can be selected by clicking on the respective tab.
 */
 
Drupal.behaviors.horizontalTabs = {
  attach: function (context) {
    for (horizontalTabs in Drupal.settings.horizontalTabs) {
      $('#horizontal-tabs-panes-' + horizontalTabs + ':not(.horizontal-tabs-processed)', context).each(function () {
        for (horizontalTab in Drupal.settings.horizontalTabs[horizontalTabs]) {
          label = Drupal.settings.horizontalTabs[horizontalTabs][horizontalTab];
          $(this).append('<li id="horizontal-tabs-tab-' + Drupal.checkPlain(horizontalTab) + '"><a href="#">' + Drupal.checkPlain(label) + '</a></li>');
          $('#horizontal-tabs-tab-' + Drupal.checkPlain(horizontalTab) + ' > a').click(function() {
            $(this).parent().parent().parent().find('.horizontal-tab-section').hide();
            $('#horizontal-tab-section-' + $(this).parent().attr('id').substr(20)).show();
            $(this).parent().parent().find('> li').removeClass('active').find('> a').removeClass('active');
            $(this).addClass('active').parent().addClass('active');
            return false;
          });
        }
        $(this).addClass('horizontal-tabs-processed');
        var active_tab = $('#' + horizontalTabs + '--active-tab').val();
        $('#horizontal-tabs-panes-' + horizontalTabs).parent().find('.horizontal-tab-section').hide();
        $('#horizontal-tab-section-' + active_tab).show();
        $('#horizontal-tabs-tab-' + active_tab).addClass('active').find('> a').addClass('active');
      });
    }
  }
};

})(jQuery);