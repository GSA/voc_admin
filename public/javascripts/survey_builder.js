// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function(){
	
	/* Functions for managing the select boxes for page and next_page 
	 * for multiple choice questions.
	 */
	$("#flow_control_checkbox").live('change', function(){

		/* If checkbox is selected then hide the next page dropdown for answers. */
		if(!$(this).is(':checked')){
			$(".simplemodal-container").css("height", "auto");
			$(".simplemodal-container").css("width", "auto");
			$(".next_pages").hide();
		} else {
			$(".simplemodal-container").css("height", "auto");
			$(".simplemodal-container").css("width", "auto");
			/* Checkbox has been checked so show the page selections */
			$(".next_pages").show();
		}
		$(window).resize();
	});
	
	/*
	 * When a page is chosen from the page selection for the question, remove that option
	 * from the flow control page select dropdown.
	 */
//	$("#choice_question_survey_element_attributes_page_id").live('change', function(){
//		$(".answer_fields .next_page_select option[value='" + 
//		$("#choice_question_survey_element_attributes_page_id option:selected").val() + "']").remove();
//	});
	
	$(".next_page_select").each(function(index){
		$(this).val($("#choice_question_survey_element_attributes_page_id option:selected").next('option').val());
	});
	
	$("#choice_question_survey_element_attributes_page_id").bind('change', function(){
		$(".next_page_select").val($("#choice_question_survey_element_attributes_page_id option:selected").next('option').val());
	});
	

	$("#choice_question_answer_type").live('change', function(){
		/*
		 * If the checkbox option is selected then show the allow multiple
		 * answers checkbox.
		 */
		if($(this).val() == "checkbox") {
			$(".simplemodal-container").css("height", "auto");
			$("#allow_multiple").show();
		}
		
		/* If multi-select is chosen then disable flow control checkbox and hide next page options */
		if($(this).val() == "multiselect"){
			$("#flow_control_checkbox").attr('checked', false).attr('disabled', true);
			$(".simplemodal-container").css("height", "auto");
			$(".simplemodal-container").css("width", "auto");
			$(".next_pages").hide();
		} else {
			
			$("#flow_control_checkbox").removeAttr('disabled');
		}
		$(window).resize();
	});
	
	/* Modal control functions */
	$(".survey_element").live('dblclick', function(){
		alert("double clicked on a question");
	})
	
	$("#link_to_new_asset").live('click', function(){
		$("#new_asset_modal").modal();
		return false;
	});
	
	$("#link_to_new_text_question").live('click', function(){
		$("#new_text_question_modal").modal();
		return false;
	});
	
	$("#link_to_new_choice_question").live('click', function(){
		$("#new_choice_question_modal").modal({autoResize:true,maxHeight:'90%',minWidth:'300px'});
		return false;
	});	
	
	$("#link_to_new_matrix_question").live('click', function(){
		$("#new_matrix_question_modal").modal({autoResize:true,maxHeight:'90%',minWidth:'300px'});
		return false;
	});
	
	$(".remove_question_link").live("ajax:success", function(event, data, status, xhr) {
		$.modal.close();
	    $("#question_list").html(data);
	});
	
	$(".remove_page_link").live("ajax:success", function(event, data, status, xhr) {
		$.modal.close();
	    $("#question_list").html(data);
	});
	
	$("#new_text_question").live("ajax:beforeSend", function(){
		$("#new_text_question div.validation_errors").html("");
	});
	
	$("#new_choice_question").live("ajax:beforeSend", function(){
		$("#new_choice_question div.validation_errors").html("");
	});
	
	$("#new_text_question").live("ajax:success", function(event, data, status, xhr){
		$.modal.close();
		$("#question_list").html(data);
		$(':input', '#new_text_question').not(':button, :submit, :reset, :hidden').reset();
	});
	$("#new_choice_question").live("ajax:success", function(event, data, status, xhr){
		$.modal.close();
		$("#question_list").html(data);
		$(':input', '#new_choice_question').not(':button, :submit, :reset, :hidden').reset();
	});
	
	$("#new_matrix_question").live("ajax:success", function(event, data, status, xhr){
		$.modal.close();
		$("#question_list").html(data);
		$(':input', '#new_matrix_question').not(':button, :submit, :reset, :hidden').reset();
	});
	
	$("#new_text_question").live("ajax:error", function(event, data, status, xhr){
		$.modal.close();
		$("#new_text_question div.validation_errors").html(data.responseText);
		$("#new_text_question_modal").modal({onClose:function(){
			$("#new_text_question div.validation_errors").html("");
			$.modal.close();
		}, persist:true});
	});
	
	$("#new_choice_question").live("ajax:error", function(event, data, status, xhr){
		$.modal.close();
		$("#new_choice_question div.validation_errors").html(data.responseText);
		$("#new_choice_question_modal").modal({onClose:function(){
			$("#new_choice_question div.validation_errors").html("");
			$.modal.close();
		}, persist:true});
	});
	
	$("#new_matrix_question").live("ajax:error", function(event, data, status, xhr){
		$.modal.close();
		$("#new_matrix_question div.validation_errors").html(data.responseText);
		$("#new_matrix_question_modal").modal({onClose:function(){
			$("#new_matrix_question div.validation_errors").html("");
			$.modal.close();
		}, persist:true});
	});
	
	
	$("#link_to_new_page").live("ajax:success", function(event, data, status, xhr){
		$("#question_list").html(data);
	});
	
	
	$("#new_asset").live("ajax:success", function(event, data, status, xhr){
		$.modal.close();
		$("#question_list").html(data);
		$(':input', '#new_asset').not(':button, :submit, :reset, :hidden').reset();
	});
	
	$("#new_asset").live("ajax:error", function(event, data, status, xhr){
		$.modal.close();
		$("#new_asset div.validation_errors").html(data.responseText);
		$("#new_asset_modal").modal({onClose:function(){
			$("#new_asset div.validation_errors").html("");
			$.modal.close();
		}, persist:true});
	});
	
	$(".element_order_up, .move_page_up, .element_order_down, .move_page_down").live("ajax:success", function(event, data, status, xhr){
		$("#question_list").html(data);
	});
		
})

function remove_fields(link) {
	$(link).prev("input[type=hidden]").val("1");
	$(link).parent().hide();
}

function add_fields(link, association, content) {  
  var new_id = new Date().getTime();  
  var regexp = new RegExp("new_" + association, "g");  
  $(link).parent().prev().after(content.replace(regexp, new_id));  
	if (association == "choice_answers" || association == "choice_questions") {
		if($("#flow_control_checkbox").is(':checked')){
			$(".next_pages").show();
		}
		
		// This is for survey_builder only
		$(".simplemodal-container").css("height", "auto").css("width", "auto");
		$(window).resize();
	}
}

function add_matrix_answers(link, content){
	var new_id = new Date().getTime();
	var regexp = new RegExp("new_matrix_answer", "g");
	$(link).parent().before(content.replace(regexp, new_id));
	
	$(".simplemodal-container").css("height", "auto").css("width", "auto");
	$(window).resize();
}

function remove_matrix_answer(link){
	$(link).parent().remove();
}