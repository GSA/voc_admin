(function($) {
  $(function() {
    bindOnSubmitForFormControls();
  });

  function bindOnSubmitForFormControls() {
    $("#preview_controls").submit(function(e) {
      if($("#version_select").val() != "") {
        removeExistingFrame();
        loadIframe($("#version_select").val(), getCssUrl());
      }
      e.preventDefault;
      return false;
    });
  }

  function getCssUrl() {
    var stylesheet = $("#custom_stylesheet").val();
    if (stylesheet == "" || stylesheet == null) {
      /* Use the text field value if no premade stylesheet selected */
      console.log("No Stylesheet was selected");
      stylesheet = $("#stylesheet_url").val();
    }
    return stylesheet;
  };

  function removeExistingFrame() {
    $("#survey_target").empty();
  };

  function loadIframe(previewUrl, cssUrl) {
    var iframe = document.createElement('iframe');
    iframe.src = previewUrl + "?stylesheetUrl=" + cssUrl;
    $("div#survey_target").append($(iframe));
  };

  function bindOnChangeForStylesheetSelect() {
    $("#version_select").on("change", function(e) {
      removeExistingFrame();
      loadIframe($(this).val(), getCssUrl());
    });
  };

}(jQuery));
