(function($) {
  $(function() {
    bindOnSubmitForFormControls();

    /* Populate the version select box based on the survey selection */
    $("#survey_id").change(function(){
      var survey_id = $(this).val();
      /* reset the version select */
      $("#survey_version_id").html("");
      /* Get the new list of versions if a survey was selected */
      if (survey_id != "") {
          getSurveyVersionList($("#survey_id").val());
      }
    });

  });

  /*
   * Make an ajax call to get the list of versions for a survey and populate the
   * select box
   */
  function getSurveyVersionList(survey_id){
    var jqxhr = $.getJSON("/surveys/" + survey_id + "/survey_versions/", {ajax:'true'}, function(j){
      var options = '';
      for(var i = 0; i < j.length ; i++){
          options += '<option value="' + j[i].value + '">' + j[i].display + '</option>';
      }
      $("#survey_version_id").html(options);
    });
  }

  function bindOnSubmitForFormControls() {
    $("#preview_controls").submit(function(e) {
      if($("#version_select").val() != "") {
        removeExistingFrame();
        loadIframe();
      }
      e.preventDefault;
      return false;
    });
  }

  function getCssUrl() {
    var stylesheet = $("#custom_stylesheet").val();
    if (stylesheet == "" || stylesheet == null) {
      stylesheet = $("#stylesheet_url").val();
    }
    return stylesheet;
  };

  function getPreviewUrl() {
    var surveyId = $("#survey_id").val();
    var surveyVersionId = $("#survey_version_id").val();
    return "/surveys/" + surveyId + "/survey_versions/" + surveyVersionId + "/preview";
  };

  function removeExistingFrame() {
    $("#survey_target").empty();
  };

  function loadIframe() {
    if($("#survey_version_id").val() == "0") {
      alert("Please select a survey version to preview");
      return;
    }
    var iframe = document.createElement('iframe');
    iframe.src = getPreviewUrl() + "?stylesheetUrl=" + getCssUrl();
    removeExistingFrame();
    $("div#survey_target").append($(iframe));
  };
}(jQuery));
