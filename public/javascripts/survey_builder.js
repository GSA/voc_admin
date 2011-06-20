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
	$("a.edit_asset_link").live('ajax:success', function(event, data, status, xhr){
		$("#edit_modal").html(data).modal({autoResize:true,maxHeight:'90%',minWidth:'330px',maxWidth:'500px'});
		return false
	});
	
	/* Open modal when control links are clicked */
	$("#link_to_new_asset, #link_to_new_text_question, #link_to_new_choice_question, #link_to_new_matrix_question").live('click', function(){
		var modal_name = $(this).attr('id').split('_').slice(2).join('_');
		$("#" + modal_name + "_modal").modal({autoResize:true,maxHeight:'90%',minWidth:'330px',maxWidth:'500px'});
		return false;
	});
		
	/* Clear out the old validation errors data before opening the modal for a new question */
	$("#new_text_question, #new_choice_question, #new_matrix_question, #new_asset").live("ajax:beforeSend", function(){
		$("#" + $(this).attr('id') + " div.validation_errors").html("");
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
		$.modal.close();
		
		var form_name = ".question_edit_form";
		var modal_name = "#edit_modal";
		
		if(!$(this).hasClass('question_edit_form')){
			var id = $(this).attr('id');
			modal_name = "#" + id + "_modal";
			form_name = "#" + id;
		}
		
		$(form_name + " div.validation_errors").html(data.responseText);
		
		$(modal_name).modal({onClose:function(){
			$(form_name + " div.validation_errors").html("");
			$.modal.close();
		}, persist:true});	

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