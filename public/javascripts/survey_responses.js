/**
 * @author jalvarado
 */


$(function(){
	/* Populate the version select box based on the survey selection */
	$("#survey_id").change(function(){
		var survey_id = $(this).val()
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
		setTimeout("setSurveyVersionSelect(" + params["survey_version_id"] + ")", 300);

	}
	
	/* Make the pagination links ajax calls */
	$("div.pagination a").live('ajax:success', function(event, data, status, xhr){
		$("#survey_response_list").html(data);
	});
	
	$(".edit_display_field_value").live('submit', function(){
		$.modal.close();
		refreshSurveyResponseTable();
	});

});

function editDisplayFieldValue(survey_id, version_id, dfv_id){
	$.ajax({
		url: "surveys/"+survey_id+"/survey_versions/"+version_id+"/display_field_values/"+dfv_id+"/edit.js",
		success: function(data){
			$("#dfv_edit_modal").html(data);
			$("#dfv_edit_modal").modal({
				onClose: function(dialog){
					/* when the modal closes, submit the form data to update the field */
					$.ajax({
						url: "surveys/"+survey_id+"/survey_versions/"+version_id+"/display_field_values/"+dfv_id,
						type: "PUT",
						data: "display_field_value[value]="+$("#display_field_value_value").val(),
						success: function(){
							getSurveyDisplayTable($("#survey_version_id").val());
						}
					});
					/* onClose function for the modal must call $.modal.close() */
					$.modal.close();
				}
			});
		}
	});
}

function setSurveyVersionSelect(survey_version_id){
	$("#survey_version_id option[value='" + survey_version_id + "']").attr('selected', 'selected');
}

function refreshSurveyResponseTable(){
	$("#survey_response_list").html("Refreshing table...");
	getSurveyDisplayTable($("#survey_version_id").val());
}

function getSurveyDisplayTable(survey_version_id){
	$.ajax({
		url: "survey_responses.js",
		data: "survey_version_id=" + survey_version_id,
		success: function(data){
			$("#survey_response_list").html(data);
		}
	})
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
	 
	 return queryStringList
}

/* Make an ajax call to get the list of versions for a survey and populate the select box */
function getSurveyVersionList(survey_id){
	var jqxhr = $.getJSON("/surveys/" + survey_id + "/survey_versions/", {ajax:'true'}, function(j){
		var options = '';
		for(var i = 0; i < j.length; i ++){
			options += '<option value="' + j[i].value + '">' + j[i].display + '</optioin>';
		}
		$("#survey_version_id").html(options);
	});
}