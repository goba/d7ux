(function ($) {

/**
 * Attaches the accordion behavior for the flooded state screens.
 */
Drupal.behaviors.accordion = {
  attach: function (context, settings) {
    $('body', context).click(function (event) {
      var target = event.target;
      accordionHideRows(target);
    });

    var table;
    for (table in settings.accordion) {
      var link = settings.accordion[table];

      $('table' + table + ':not(.accordion-processed)', context).each(function () {
        Drupal.accordions.prepare(this, link);
      }).addClass('accordion-processed');

      // Bind the ajaxSubmit behavior to all accordion-loaded forms.
      $('table' + table + ' form:not(.accordion-processed)').each(function () {
        $(this).submit(function () {
          $(this).children('div').append('<div class="accordion-throbber"/>');
          var options = {
            success: function (response) {
              var messages = Drupal.parseJson(response.messages);
              messages = typeof messages == 'object' ? messages.data : '';
              var ajaxResponse = $('#ajaxform-response').html(messages);
              ajaxResponse.find('a').click(function() {
                $(this).closest('tr.accordion-row').remove();
                var tr = $(this).closest('tr.accordion-row').get(0).previousSibling;
                $(tr).removeClass('active').find('div.accordion-options div.option').removeClass('active');
                return false;
              });
              ajaxResponse.siblings().remove();
            },
            dataType: 'json'
          };
          $(this).ajaxSubmit(options);
          $(this).find(':input').attr('disabled', 'disabled');
          return false;
        });
        $(this).find('a.cancel-link').click(function() {
          var tr = $(this).closest('tr.accordion-row').get(0).previousSibling;
          $(this).closest('tr.accordion-row').remove();
          $(tr).removeClass('active').find('div.accordion-options div.option').removeClass('active');
          return false;
        });
      }).addClass('accordion-processed');
    }
  }
}

Drupal.accordions = Drupal.accordions || {};

// Setting up the inital behaviours.
Drupal.accordions.prepare = function (el, link) {
  $(el).find('tr')
  .hover(function () {
    $(this).addClass('hover');
  }, function () {
    $(this).removeClass('hover');
  })
  .find(link).addClass('accordion-options').each(function () {
    var i = 0;
    var idArray = this.id.split('-');
    var entityType = idArray[0];
    var hid = idArray[2];
    $(this).find('div.option a').each(function () {
      this.tabIndex = i++;
      this.hid = hid;
      this.entityType = entityType;
      $(this).bind('click', function () {
        accordionHideRows(this);
        var table = $(this).closest('table');
        var link = Drupal.settings.accordion['#' + table.attr('id')];
        return accordionClick(this, link);
      });
    });
  }).addClass('accordion-options');
}

Drupal.accordions.tab = function (el) {
  this.element = el;
  var myId = el.id.split('-');
  this.entityType = el.entityType;
  this.entityOp = myId[1];
  this.entityId = myId[2];
  this.tabIndex = el.tabIndex;
  this.hid = el.hid;

  var tab = this;
  this.options = {
    success: function (response) {
      return tab.success(response);
    },
    complete: function (response) {
      return tab.complete();
    }
  };
}

// AJAX callback.
Drupal.accordions.tab.prototype.success = function (response) {
  var result = Drupal.parseJson(response.data);
  var javaScript = Drupal.parseJson(response.javaScript);
  var css = Drupal.parseJson(response.css);
  result = typeof result == 'object' ? result.data : '';
  javaScript = typeof javaScript == 'object' ? javaScript.data : '';
  css = typeof css == 'object' ? css.data : '';
  $(javaScript).filter(function() {
    var alreadyAdded = false;
    var src = $(this).attr('src');
    if (typeof src == 'string' && src.length) {
      $('script').each(function() {
        if ($(this).attr('src') == src) {
          alreadyAdded = true;
        }
      });
    }
    return !alreadyAdded;
  }).each(function() {
    $(this).insertAfter('script:last');
  });
  $(css).filter(function() {
    var alreadyAdded = false;
    var href = $(this).attr('src');
    if (typeof href == 'string' && href.length) {
      $('link').each(function() {
        if ($(this).attr('type') == 'text/css' && $(this).attr('href') == href) {
          alreadyAdded = true;
        }
      });
    }
    return !alreadyAdded;
  }).each(function() {
    $(this).insertAfter('link[type=text/css]:last');
  });
  this.container.html(Drupal.theme('accordionResponse', this, result));
  $('#tab-content-' + this.hid + '-' + this.tabIndex).slideDown('slow');
  Drupal.attachBehaviors(this.container);
}

// Function to call on completed ajax call.
Drupal.accordions.tab.prototype.complete = function () {
  // Stop the progress bar.
  this.stopProgress();
}

Drupal.accordions.tab.prototype.stopProgress = function () {
  if (this.progress.element) {
    $(this.progress.element).remove();
  }
  $(this.element).removeClass('progress-disabled').attr('disabled', false);
}

Drupal.accordions.tab.prototype.startProgress = function () {
  var progressBar = new Drupal.progressBar('accordion-progress-' + this.element.id, null, null, null);
  progressBar.setProgress(-1, Drupal.t('Loading...'));
  this.progress = {};
  this.progress.element = $(progressBar.element).addClass('accordion-progress accordion-progress-bar');
  this.container.prepend(this.progress.element);
}

var accordionClick = function (a, link) {
  var hid = $(a).attr('hid');
  var entityType = $(a).attr('entityType');
  var tabIndex = $(a).attr('tabIndex');
  if (!$('#accordion-container-' + hid).size()) {
    var newContainer = $('<tr></tr>').attr('id', 'accordion-container-' + hid).addClass('accordion-row');
    newContainer.append('<td colspan="7"></td>').insertAfter($('#' + entityType + '-accordion-' + hid).parents('tr'));
  }
  // Only make the ajax request if the form is not already there.
  if (!$('#tab-content-' + hid + '-' + tabIndex).size()) {
    // Set clicked tab to active.
    $(a).parents('div.option').siblings().removeClass('active');
    $(a).parents('div.option').addClass('active');

    // Set this row to active.
    $(a).closest('tr').addClass('active');

    if ($('#accordion-container-' + hid).find('.accordion-form form').size()) {
      $('#accordion-container-' + hid).find('.accordion-form').remove();
    }

    var tab = new Drupal.accordions.tab(a);
    $('tr.accordion-row:not(#accordion-container-' + hid + ')').remove();

    tab.container = $('#accordion-container-' + hid).children('td');

    tab.startProgress();
    // Construct the ajax path to retrieve the content, depending on type.
    var qtAjaxPath = Drupal.settings.basePath + (location.href.indexOf('?q=') != -1 ? '?q=' : '') + 'edit/inline/' + tab.entityType + '/' + tab.entityOp + '/' + tab.entityId;

    $.ajax({
      url: qtAjaxPath,
      type: 'GET',
      data: null,
      success: tab.options.success,
      complete: tab.options.complete,
      dataType: 'json'
    });
  }
  return false;
}

var accordionHideRows = function (target) {
  $('tr.accordion-row').filter(function () {
    var row = this;
    var exempt = false;
    // The row(s) that were clicked on are exempt.
    $(target).parents('tr.accordion-row').each(function () {
      if (row == this) {
        exempt = true;
      }
    });
    if (!exempt) {
      $(this.previousSibling).removeClass('active').find('div.accordion-options div.option').removeClass('active');
    }
    return !exempt;
  }).remove();
}

// Theme function for ajax response.
Drupal.theme.prototype.accordionResponse = function (tab, result) {
  var newContent = '<div id="ajaxform-response" class="message status"></div><div id="tab-content-' + tab.hid + '-' + tab.tabIndex + '" class="accordion-form">' + result + '</div>';
  return newContent;
};

})(jQuery);