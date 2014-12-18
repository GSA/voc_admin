/* Use an immediately invoked function to isolate variables */
(function(jQuery){

  jQuery(function() {
    jQuery('#invitation_preview').on('click', function(e) {
      showPreview();
    });
  });

  function acceptText() {
    var text = jQuery('#survey_invitation_accept_button_text').val();
    if(text.length > 0 ) {
      return text;
    } else {
      return "Yes";
    }
  }

  function rejectText() {
    var text = jQuery('#survey_invitation_reject_button_text').val();
    if(text.length > 0 ) {
      return text;
    } else {
      return "No";
    }
  }

  function showPreview(){
    var invitationText = jQuery('#survey_invitation_text').val();
    var stylesheetUrl  = jQuery('#survey_invitation_preview_stylesheet').val();

    if(invitationText.length == 0) return;

    invitationHtml = invitationText.replace("{{accept}}",
      '<input type="button" name="vocEnter" id="vocEnter" value="' + acceptText() + '">');
    invitationHtml = invitationHtml.replace('{{reject}}',
      '<input type="button" name="vocCancelButton" class="vocCancelButton" value="' + rejectText() + '">');

    invitationHtml = "<div style='width:100%'><div id='vocModal' aria-hidden='true' aria-labelledby='modalTitle' aria-describedby='modalDescription' role='dialog' tabindex='-1'>"
      + invitationHtml
      + "</div></div><div id='vocModalOverlay'></div>";

    var popurl = "";
    invitationPreview = window.open(popurl, "", "scrollbars,");
    invitationPreview.document.write(invitationHtml)

    // Add the default styles
    var head = invitationPreview.document.head
      , defaultStylesheet = invitationPreview.document.createElement('link');
    defaultStylesheet.type = 'text/css';
    defaultStylesheet.rel = 'stylesheet';
    defaultStylesheet.href = '/stylesheets/invite_preview.css';
    head.appendChild(defaultStylesheet)

    if(stylesheetUrl.length > 0) {
      var head = invitationPreview.document.head
        , link = invitationPreview.document.createElement('link');
      link.type = 'text/css';
      link.rel = 'stylesheet';
      link.href = stylesheetUrl;
      head.appendChild(link);
    }

  }

})(jQuery);
