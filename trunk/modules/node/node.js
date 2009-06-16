// $Id: node.js,v 1.4 2009/04/27 20:19:37 webchick Exp $

(function ($) {

Drupal.behaviors.nodeFieldsetSummaries = {
  attach: function (context) {
    $('fieldset#edit-revision-information', context).setSummary(function (context) {
      return $('#edit-revision', context).is(':checked') ?
        Drupal.t('New revision') :
        Drupal.t('No revision');
    });

    $('fieldset#edit-author', context).setSummary(function (context) {
      var name = $('#edit-name').val(), date = $('#edit-date').val();
      return date ?
        Drupal.t('By @name on @date', { '@name': name, '@date': date }) :
        Drupal.t('By @name', { '@name': name });
    });

    $('fieldset#edit-options', context).setSummary(function (context) {
      var vals = [];

      $('input:checked', context).parent().each(function () {
        vals.push(Drupal.checkPlain($.trim($(this).text())));
      });

      if (!$('#edit-status', context).is(':checked')) {
        vals.unshift(Drupal.t('Not published'));
      }
      return vals.join(', ');
    });
  }
};

/**
 * Enables users to easily switch between node types on the node creation form.
 */
Drupal.behaviors.nodeSwitchType = {
  attach: function (context) {
    if (typeof Drupal.settings.nodeTypes != 'object') {
      return;
    }

    $('#node-form', context).each(function() {
      // If the switch select box is present on the parent element, then we are
      // attaching behaviors to a node form that already exhibits our behavior,
      // so abort to avoiding adding the behavior twice.
      if ($(this).parent().find('#edit-switch').size()) {
        return;
      }

      // Generate the HTML for the select options.
      var options = '';
      for (type in Drupal.settings.nodeTypes) {
        options += '<option value="' + type + '"' + (Drupal.settings.nodeType == type ? ' selected="selected"' : '') + '>' + Drupal.checkPlain(Drupal.settings.nodeTypes[type]) + '</option>';
      }
      // Add the form item to the page before the node form, so that the select
      // box doesn't disappear when switching between node types.
      console.log(this);
      $(this).before('<form accept-charset="UTF-8" method="post"><div id="edit-switch-wrapper" class="form-item form-item-select switch-wrapper container-inline">'
                        + '<label for="edit-switch">' + Drupal.t('Switch content types') + ': </label>'
                        + '<select id="edit-switch" class="form-select" name="switch">'
                          + options
                        + '</select>'
                      + '</div></form>');

      // Attach the switching behavior to the change event of the select box so
      // it will be called when we need to change content type forms.
      $('#edit-switch').change(function() {
        var node_type = $(this).val();
        // Store the form action, since the HTTP request will incorrectly point
        // to the javascript page.
        var action = $(this).parent().parent().parent().find('> #node-form').attr('action');
        // If the form is already of the node type currently selected, abort to
        // avoid an unnecessary AJAX request.
        if (node_type == Drupal.settings.nodeType) {
          return;
        }
        // Add a throbber to indicate that we're working on retrieving the node
        // form requested, and disable the select list.
        $(this).after('<div class="node-switch-throbber throbber">&nbsp;</div>');
        if (typeof Drupal.settings.nodeStoredData == 'undefined') {
          Drupal.settings.nodeStoredData = {};
        }
        $(this).attr('disabled', 'disabled');

        var form = $('#node-form');
        // Put all the input data into an object keyed by elements' names, such
        // that it's readily available to be reinserted into another node form.
        // We keep all data stored, even if it has no equivalent element in the
        // other form, for the case that the user decides to switch back to the
        // original form.
        form.find(':input').each(function() {
          var name = $(this).attr('name');
          if (typeof name == 'string' && name.length && name != 'form_build_id' && name != 'form_token' && name != 'form_id' && name != 'op') {
            // For checkboxes, store whether or not it is checked instead of an
            // arbitrary value.
            if ($(this).is(':checkbox')) {
              Drupal.settings.nodeStoredData[name] = $(this).is(':checked');
            }
            // For radio buttons, only store the value if the radio is checked.
            else if ($(this).is(':radio')) {
              if ($(this).is(':checked')) {
                Drupal.settings.nodeStoredData[name] = $(this).val();
              }
            }
            // For everything else, just store the value.
            else {
              Drupal.settings.nodeStoredData[name] = $(this).val();
            }
          }
        });

        // Make the request to Drupal, which will return the node form as plain
        // HTML.
        $.get(Drupal.settings.basePath + 'node/form/js/' + node_type.replace(/_/g, '-'), {}, function(new_form) {
          // Replace the old form with the new form and attach behaviors to the
          // new form. We need to attach behaviors before changing the value of
          // elements, because some elements may have behaviors that will react
          // to the element being changed.
          form.replaceWith(new_form);
          form = $('#node-form');
          // Change the form action to the correct value, obtained by replacing
          // the original node type string with the new node type string in the
          // value.
          form.attr('action', action.replace(Drupal.settings.nodeType.replace(/_/g, '-'), node_type.replace(/_/g, '-')));
          Drupal.attachBehaviors(form);
          form.find(':input').each(function() {
            var name = $(this).attr('name');
            if (typeof name == 'string' && name.length && typeof Drupal.settings.nodeStoredData[name] != 'undefined') {
              // With checkboxes, we don't change the value; instead, we change
              // the "checked" attribute.
              if ($(this).is(':checkbox')) {
                if (Drupal.settings.nodeStoredData[name]) {
                  $(this).attr('checked', 'checked').change();
                }
                else {
                  $(this).removeAttr('checked').change();
                }
              }
              // With radios, we also don't change the value; instead, we alter
              // the "checked" attribute, checking it only if its value matches
              // the value stored.
              else if ($(this).is(':radio')) {
                if ($(this).val() == Drupal.settings.nodeStoredData[name]) {
                  $(this).attr('checked', 'checked').change();
                }
                else {
                  $(this).removeAttr('checked').change();
                }
              }
              // For all other elements, just set the value to the stored data.
              else {
                $(this).val(Drupal.settings.nodeStoredData[name]).change();
              }
            }
          });

          // Now we need to change the titles to indicate we are on a different
          // node form.
          var old_title = Drupal.t('Create @name', {'@name': Drupal.settings.nodeTypes[Drupal.settings.nodeType]});
          var title = Drupal.t('Create @name', {'@name': Drupal.settings.nodeTypes[node_type]});
          $('h1,h2,h3,h4,h5,h6').each(function() {
            if (this.innerHTML == old_title) {
              this.innerHTML = title;
            }
          });
          // Don't escape for the document title, doing so would result in text
          // escaped twice.
          document.title = Drupal.t('Create !name', {'!name': Drupal.settings.nodeTypes[node_type]});

          // Change the "active" class on links to reflect the change in active
          // page.
          var old_url = Drupal.settings.basePath + 'node/add/' + Drupal.settings.nodeType.replace(/_/g, '-');
          var new_url = Drupal.settings.basePath + 'node/add/' + node_type.replace(/_/g, '-');
          $('a').each(function() {
            if ($(this).attr('href') == old_url) {
              $(this).removeClass('active');
            }
            if ($(this).attr('href') == new_url) {
              $(this).addClass('active');
            }
          });
          // Set the stored node type to the type we switched to.
          Drupal.settings.nodeType = node_type;
          // Now we're finished with switching node types, so enable the select
          // list and remove the throbber.
          $('#edit-switch').removeAttr('disabled').siblings('div.throbber').remove();
        });
      });
    });
  }
}

})(jQuery);
