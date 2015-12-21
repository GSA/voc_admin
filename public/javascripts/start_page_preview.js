$(function() {
  $("#start_page_preview").on("click", function(e) {
    var survey_id = $(this).data("id");
    var popurl = "/surveys/" + survey_id + "/start_page_preview";
    var preview_stylesheet = $("#survey_survey_preview_stylesheet").val();
    popurl = popurl + "?stylesheet=" + preview_stylesheet;
    window.open(popurl, "", "width=600,height=270, scrollbars,");
    e.preventDefault();
    return false
  });
});
