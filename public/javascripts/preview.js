$(function() {
  $("#preview_controls").submit(function(e) {
    if($("#version_select").val() != "") {
      removeExistingFrame();
      loadIframe($("#version_select").val(), $("#stylesheet_url").val());
    }
    e.preventDefault;
    return false;
  });
  $("#version_select").on("change", function(e) {
    removeExistingFrame();
    loadIframe($(this).val(), $("#stylesheet_url").val());
  });
});

function removeExistingFrame() {
  $("#survey_target").empty();
}

function loadIframe(previewUrl, cssUrl) {
  var iframe = document.createElement('iframe');
  iframe.src = previewUrl + "?stylesheetUrl=" + cssUrl;
  $("div#survey_target").append($(iframe));
};
