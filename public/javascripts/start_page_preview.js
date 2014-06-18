$(function() {
  $("#start_page_preview").on("click", function() {
    var survey_id = $(this).data("id");
    var popurl = "/surveys/" + survey_id + "/start_page_preview";
    var preview_stylesheet = $("#survey_survey_preview_stylesheet").val();
    popurl = popurl + "?stylesheet=" + preview_stylesheet;
    window.open(popurl, "", "width=600,height=270, scrollbars,");
  });
});

// var pageurl  = window.location.origin + window.location.pathname;
// var popurl = "http://<%= APP_CONFIG['host'] %>/surveys/<%= @survey.id %>/holding_page?"
// <% if params[:stylesheet] %>
// popurl = popurl + "stylesheet=<%= params[:stylesheet] %>&";
// <% end %>
// popurl = popurl + "page_url=" + pageurl;
// window.open(popurl,"","width=600,height=270,scrollbars,");
