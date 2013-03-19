var search_timer_id = null;
var last_ajax_request_id = 0;

$(function(){
    $(".editDisplayFieldValue").live('ajax:success', function(event, data, status, xhr){
            $("#dfv_edit_modal").html(data);
            $("#dfv_edit_modal").modal();
    });

    /* replace the survey_response_list when a delete call is made */
    //$(".archive_link").live('ajax:success', refreshSurveyResponseTable);

    /* Populate the version select box based on the survey selection */
    $("#survey_id").change(function(){
        var survey_id = $(this).val();
        /* reset the version select */
        $("#survey_version_id").html("");
        /* remove the display table if one already is shown */
        $("#survey_response_list").html("");
        /* Get the new list of versions if a survey was selected */
        if (survey_id != "") {
            getSurveyVersionList($("#survey_id").val());
        }
    });


    /* make an ajax call to display the survey responses based on version_selection */
    $("#survey_version_id").change(function(){
        var survey_version_id = $(this).val();

        /* blank out the search field */
        $("#search").val('');

        /*
         * remove currently displayed responses if no version selected.  Otherwise
         * make an ajax call to get the display table for the selected version
         */
        if(survey_version_id == "0"){
            $("#survey_response_list").html("");
        } else {
            getSurveyDisplayTable($("#survey_version_id").val());
        }
    });

    /* if params exist preset the selects to those versions */
    var params = getUrlParams();
    /* If there are params passed then pre-populate the select boxes */
    if(params["survey_id"] && params["survey_version_id"]){
        $("#survey_id").val(params["survey_id"]);
        getSurveyVersionList($("#survey_id").val());
        /* This has to be done for some reason in order to give time for the DOM to register the
         * previous insertion of select options.
         */
        setTimeout("setSurveyVersionSelect(" + params["survey_version_id"] + ")", 1000);
    }

    /* Make the pagination links ajax calls */
    $("div.pagination a").live('ajax:beforeSend', function(){
        $("#survey_response_list").html("<img src='/images/ajax-loader-response-table.gif' style='margin-top: 75px;margin-left: 275px;' />");
    });

    $(".edit_display_field_value").live('submit', function(){
        $.modal.close();
        refreshSurveyResponseTable();
    });

    /* When performing either search method, replace the survey results with the ajax spinner;
     * save a copy of the survey results displayed and replace in 5 seconds if there's an error/timeout
     * -- this mechanism could be improved.
     */
    $("#advanced_search_form, #simple_search_form").live('ajax:beforeSend', function() {
        var old_html = $("#survey_response_list").html();
        searchTimeout = setTimeout(function() {
            $("#survey_response_list").html(old_html);
        }, 5000);

        $("#survey_response_list").html("<img src='/images/ajax-loader-response-table.gif' style='margin-top: 75px;margin-left: 275px;' />");
    });

    /* If the search AJAX request comes back, turn off the timer to replace with stale content. */
    $("#advanced_search_form, #simple_search_form").live('ajax:success', function(event, data, status, xhr){
        clearTimeout(searchTimeout);
    });

    $('select[name="custom_view"]').live("change", change_responses_view);
});

function add_search_criteria(link, content){
  var new_criteria_index = new Date().getTime();
  var regexp = new RegExp('new_criteria_index', 'g');

  $("#searchCriterias").append(content.replace(regexp, new_criteria_index));
}


function editDisplayFieldValue(survey_id, version_id, dfv_id){
    $.ajax({
        url: "surveys/"+survey_id+"/survey_versions/"+version_id+"/display_field_values/"+dfv_id+"/edit.js",
        success: function(data){
            $("#dfv_edit_modal").html(data);
            $("#dfv_edit_modal").modal();
        }
    });
}

function setSurveyVersionSelect(survey_version_id){
    $("#survey_version_id option[value='" + survey_version_id + "']").attr('selected', 'selected');

}

function refreshSurveyResponseTable(){
    var order_column = $("#order_column").val();
    var order_dir = $("#order_dir").val();
    var survey_version_id = $("#survey_version_id").val();
    var custom_view_id = $("#custom_view_id").val();
    var page_num = $("#page").val();


    /* Do not make the ajax call if no survey_version_id has been selected */
    if(survey_version_id != null && survey_version_id != undefined && survey_version_id != "0"){
        $("#survey_response_list").html("Refreshing table...");
        getSurveyDisplayTable(survey_version_id, order_column, order_dir, custom_view_id, page_num);
    }

}

function getSurveyDisplayTable(survey_version_id, order_column, direction, custom_view_id, page_num){
    if(order_column == undefined) { order_column = ''; }
    if(direction == undefined) { direction = ''; }
    if(custom_view_id == undefined) { custom_view_id = '';}
    if(page_num == undefined) { page_num = 1;}

    var search_form_url_string = $("#advanced_search_form").serialize();

    var data_string = search_form_url_string + "&order_column=" + order_column + "&order_dir=" + direction + "&survey_version_id=" + survey_version_id + "&custom_view_id=" + custom_view_id + "&page=" + page_num;
    last_ajax_request_id += 1;

    $.ajax({
        url: "survey_responses.js",
        data: data_string, //"survey_version_id=" + survey_version_id + "&search=" + search_text + "&order_column=" + order_column + "&order_dir=" + direction,
        dataType: "script",
        beforeSend: function(){
            $("#survey_response_list").html("<img src='/images/ajax-loader-response-table.gif' style='margin-top: 75px;margin-left: 275px;' />");
        }
    })
}

function sortByDisplayField(column_id, direction){
    getSurveyDisplayTable($("#survey_version_id").val(), column_id, direction, $("#custom_view_id").val(), $("#page").val());
}

function getUrlParams(){
    // get the current URL
     var url = window.location.toString();
     //get the parameters
     url.match(/\?(.+)$/);
     var params = RegExp.$1;
     // split up the query string and store in an
     // associative array
     var params = params.split("&");
     var queryStringList = {};

     for(var i=0;i<params.length;i++)
     {
         var tmp = params[i].split("=");
         queryStringList[tmp[0]] = unescape(tmp[1]);
     }

     return queryStringList;
}

/* Make an ajax call to get the list of versions for a survey and populate the select box */
function getSurveyVersionList(survey_id){
    var jqxhr = $.getJSON("/surveys/" + survey_id + "/survey_versions/", {ajax:'true'}, function(j){
        var options = '';
        for(var i = 0; i < j.length ; i++){
            options += '<option value="' + j[i].value + '">' + j[i].display + '</option>';
        }
        $("#survey_version_id").html(options);
    });
}

function remove_search_criteria(link) {
    $(link).parent().remove();
}

function change_responses_view(ev) {
    ev.preventDefault();

    // set the custom view to post back
    $("#custom_view_id").val(this.value);

    // since we're changing views, go back to page 1 of responses
    $("#page").val(1);

    refreshSurveyResponseTable();
}