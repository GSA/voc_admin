/**
 * @author jalvarado
 */


$(function(){
	$("#survey_id").change(function(){
		var survey_id = $(this).val()
		$("#survey_version_id").html("");
		$("#survey_response_list").html("");
		if (survey_id != "") {
			var jqxhr = $.getJSON("/surveys/" + survey_id + "/survey_versions/", {ajax:'true'}, function(j){
				var options = '';
				for(var i = 0; i < j.length; i ++){
					options += '<option value="' + j[i].value + '">' + j[i].display + '</optioin>';
				}
				$("#survey_version_id").html(options);
			});
		}
	});
	
	$("#survey_version_id").change(function(){
		var survey_version_id = $(this).val();
		
		if(survey_version_id == ""){
			$("#survey_response_list").html("");
		} else {
			$.ajax({
				url: "survey_responses.js",
				data: "survey_version_id=" + $("#survey_version_id").val(),
				success: function(data){
					$("#survey_response_list").html(data);
				}
			})
		}
	});
});