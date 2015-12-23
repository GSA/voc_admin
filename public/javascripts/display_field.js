$(function(){
	$(document).on('change', 'select#display_field_model_type', function(e) {
		if($(this).val() == "DisplayFieldText"){
			text_type_actions();
		} else if($(this).val() == "DisplayFieldChoiceSingle") {
			dropdown_type_actions();
		} else if(($(this).val() == "DisplayFieldChoiceMultiselect")) {
			multiselect_type_actions();
		}
	});
});

function text_type_actions(){
	//Hide choices
	$('#choices_fields').hide();
	//Flip the default value to a text field
	input_tag = "<input type='text' size='30' name='display_field[default_value]' id='display_field_default_value' style='display: inline;'>";
	$('#display_field_default_value').replaceWith(input_tag);
	//Show default fields
	$('#default_value_fields').show();
	//Hide the refresh link
	$('a#refresh_link').hide();
}

function dropdown_type_actions(){
	//Show choices
	$('#choices_fields').show();
	//Flip the default value to a dropdown
	select_tag = "<select id='display_field_default_value' style='' name='display_field[default_value]'><option value=''>SELECT ONE</option></select>";
	$('#display_field_default_value').replaceWith(select_tag);
	//Show default fielimageds + label
	$('#default_value_fields').show();
	//Show the refresh link
	$('a#refresh_link').show();
}

function multiselect_type_actions(){
	//Show choices
	$('#choices_fields').show();
	//Hide default value dropdown or text field + label
	$('#default_value_fields').hide();
}

function refresh_default_value_dropdown(){
	choices = $('textarea#display_field_choices').val().split('\n');
	select_tag = $('select#display_field_default_value');

	select_tag.html("");
	$.each(choices, function(index, val) {
		select_tag.append("<option value=" + val + ">" + val + "</option>");
	});
}
