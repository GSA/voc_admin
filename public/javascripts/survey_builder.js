$(function(){
	
	/* Functions for managing the select boxes for page and next_page 
	 * for multiple choice questions.
	 */
	$("#flow_control_checkbox").live('change', function(){
		var width = 0;
		/* If checkbox is selected then hide the next page dropdown for answers. */
		if(!$(this).is(':checked')){
			$(".next_pages").hide();
			width =  $("#edit_modal").width() - $(".next_pages:first").width();
		} else {
			/* Checkbox has been checked so show the page selections */
			$(".next_pages").show();
			width = $("#edit_modal").width() + $(".next_pages:first").width();
		}
		resizeModal($("#edit_modal").height(), width);
	});
	
	/*
	 * When a page is chosen from the page selection for the question, remove that option
	 * from the flow control page select dropdown.
	 */
	// TODO: Implement this
	
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
			$("#allow_multiple").show();
		}
		
		/* If multi-select is chosen then disable flow control checkbox and hide next page options */
		if($(this).val() == "multiselect"){
			$("#flow_control_checkbox").attr('checked', false).attr('disabled', true);
			$(".next_pages").hide();
		} else {
			$("#flow_control_checkbox").removeAttr('disabled');
		}
		resizeModal($("#edit_modal").height(), $("#edit_modal").width());
	});
	
	/* Modal control functions */
	$("a.edit_asset_link").live('ajax:success', function(event, data, status, xhr){
		$("#edit_modal").html(data).modal({autoResize:true,maxHeight:'90%',minWidth:'330px',maxWidth:'500px'});
		return false
	});
	
	/* Make an ajax call to pull the 'new' form from the server for a question */
	$("#link_to_new_asset, #link_to_new_text_question, #link_to_new_choice_question, #link_to_new_matrix_question").live('ajax:success', function(event, data, status, xhr){
		$("#edit_modal").html(data).modal({autoResize:true, maxHeight:'90%', minWidth:'330px', maxWidth:'500px'});
	});
		
	
	/* Update the question list and clear out the submitted data from the modal when a question is successfully added to the survey */
	$("#new_text_question, #new_choice_question, #new_matrix_question, #new_asset, .question_edit_form").live("ajax:success", function(event, data, status, xhr){
		$.modal.close();
		$("#question_list").html(data);
		if(!$(this).hasClass('question_edit_form')) {
			$(':input', "#" + $(this).attr('id')).not(':button, :submit, :reset, :hidden').reset();			
		}
	});
	
	/* Update the modal with the validation errors if the ajax response comes back with an error code when creating a new question/asset */
	$("#new_text_question, #new_choice_question, #new_matrix_question, #new_asset, .question_edit_form").live("ajax:error", function(event, data, status, xhr){
		$("#edit_modal").html(data.responseText);
		
		var modalContainer = $("#simplemodal-container");
		resizeModal($("#edit_modal").height(), $("#edit_modal").width());
	});
	
	/* hide the spinner and update the question list when a successful response is received from an ajax request to reorder an element/page */
	$(".element_order_up, .move_page_up, .element_order_down, .move_page_down, #link_to_new_page, .remove_page_link, .remove_question_link").live("ajax:success", function(event, data, status, xhr){
		$("#question_list").html(data);
		toggleSpinner();
	});
	
	/* Show the spinner on ajax requests to reorder elements/pages */
	$(".element_order_up, .move_page_up, .element_order_down, .move_page_down, #link_to_new_page, .remove_page_link, .remove_question_link").live("ajax:beforeSend", function(){
		toggleSpinner();
	});
		
}) // End onLoad function

function toggleSpinner(){
	$("#spinner_overlay").toggle();
}

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
		resizeModal($("#edit_modal").height(), Math.max($("#edit_modal").width(), $(".simplemodal-container").width()));
	}
}

function add_matrix_answers(link, content){
	var new_id = new Date().getTime();
	var regexp = new RegExp("new_matrix_answer", "g");
	$(link).parent().before(content.replace(regexp, new_id));
	
	resizeModal($("#edit_modal").height(), Math.max($("#edit_modal").width(), $(".simplemodal-container").width()));
}

function remove_matrix_answer(link){
	$(link).parent().remove();
	resizeModal($("#edit_modal").height(), $("#edit_modal").width());
}

function resizeModal(height, width){
	$(".simplemodal-container").css("height", height).css("width", width);
	$.modal.setPosition();
}

function swapAnswers(link, direction){
	var current_field = $(link).siblings('input:text').first();
	var previous_field = null;
	if(direction == "up"){
		previous_field = $(link).parent().prevAll('p.answer_fields').first().children('input:text').first();
	} else {
		previous_field = $(link).parent().nextAll('p.answer_fields').first().children('input:text').first();
	}
	
	
	if(previous_field.length){
		var current_field_value = current_field.val();
		current_field.val(previous_field.val());
		previous_field.val(current_field_value);

	}
}