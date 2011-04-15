// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function(){
	$(".survey_element").live('dblclick', function(){
		alert("double clicked on a question");
	})
	
	$("#link_to_new_text_question").live('click', function(){
		$("#new_text_question_modal").modal();
		return false;
	});
	
	$("#link_to_new_choice_question").live('click', function(){
		$("#new_choice_question_modal").modal();
		return false;
	});	
	
	$(".button_to").live("ajax:success", function(event, data, status, xhr) {
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
	
	$("#link_to_new_page").live("ajax:success", function(event, data, status, xhr){
		$("#question_list").html(data);
	});
})