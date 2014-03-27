$(function(){
	generateSelectedDisplayFieldsParameter();
	populateSortOptionsFromSelectedDisplayFields();
	selectOptionsFromSortingParameter();

	$("#add_display_fields").click(addFields);
	$("#remove_display_fields").click(removeFields);
	$("#move_display_field_up").click(moveUp);
	$("#move_display_field_down").click(moveDown);

	$("#sort_by_1, #sort_by_2, #sort_by_3, input[type=radio][name^=sort_by_]").change(generateSortingParameterFromDropdowns);

}); // End onLoad binding

// the Display Fields for the view are brought back as contents of the multiselect from the server;
// this function ensures that the hidden field is synched (edit Custom View).
function generateSelectedDisplayFieldsParameter() {

	// select boxes normally only post selected values; this workaround ensures
	// all values in the right box get posted
	var selectedDisplayFields = $("#selected_display_fields option").map(function(){ return this.value }).get();
	$('input[name="custom_view[ordered_display_fields][selected]"]').val(selectedDisplayFields);
}

// copy the available field options into the ordering dropdowns on load (edit Custom View)
function populateSortOptionsFromSelectedDisplayFields() {
	$("#selected_display_fields option").clone().appendTo("#sort_by_1, #sort_by_2, #sort_by_3");
}

// grab the hidden field element which contains the Custom View ordering instructions
function getSortingParameter() {
	return $('input[name="custom_view[ordered_display_fields][sorts]"]');
}

// on load, parse the ordering string and set the "order by" dropdowns appropriately
// ex: "col1:asc,col2:desc,col3:asc"
function selectOptionsFromSortingParameter() {
	var orderString = getSortingParameter().val();

	$.each(orderString.split(','), function(idx, ord) {
		var order = ord.split(':');
		var el = "#sort_by_" + (idx + 1);

		$(el + " option[value='" + order[0] + "']").attr('selected', true);
		$(el + "_dir_" + order[1]).attr('checked', true);
	});
}

// turns dropdown selections for ordering columns back into "col1:asc,col2:desc,col3:asc" format
function generateSortingParameterFromDropdowns() {
	var sortOrders = getSortingParameter();

	// map through the array to generate the list of params
	var orderedDisplayFields = $([1, 2, 3]).map(function() {
		var el = "sort_by_" + this;

		var selected = $("#" + el + " option:selected").val();

		// ignore the "SELECT COLUMN" option
		if (selected > -1) {
			var order = $("[name=" + el + "_dir]:checked").val();

			// if there isn't already a sort direction selected, choose ASC
			if (!order) {
				$("#" + el + "_dir_asc").attr('checked', true);
			}

			return selected + ":" + (order ? order : "asc");
		}
	});

	// jQuery returns an object from $.map; $.makeArray fixes it.
	sortOrders.val($.makeArray(orderedDisplayFields));
}

function addFields() {
	// remove from available_display_fields
	var selectedOptions = $("#available_display_fields option:selected").remove();

	// add to selected_display_fields
	// add options to each of the three sort_by_ select tags
	selectedOptions.attr('selected', false).appendTo('#selected_display_fields, #sort_by_1, #sort_by_2, #sort_by_3');

	generateSelectedDisplayFieldsParameter();
	return false;
}

// get the list of selected display fields for list/dropdown manipulations
function getSelected() {
	return $("#selected_display_fields option:selected");
}

function removeFields() {
	// remove from selected_display_fields
	var selectedOptions = getSelected().remove();

	// remove options from each of the three sort_by select tags
	//   (and reset to "SELECT COLUMN" if it was chosen)
	selectedOptions.each(function() {
		$("#sort_by_1, #sort_by_2, #sort_by_3").find("option[value=" + $(this).val() + "]").remove();
	});

	// add to available_display_fields
	selectedOptions.appendTo('#available_display_fields');

	generateSelectedDisplayFieldsParameter();
	generateSortingParameterFromDropdowns();
	return false;
}

function moveUp() {
	// move around options in selected fields list, supports single-select only
	var selected = getSelected();
	if (selected.length == 1) selected.insertBefore(selected.prev());

	// works around IE7 bad behavior
	$("#selected_display_fields").focus();

	generateSelectedDisplayFieldsParameter();
	return false;
}

function moveDown() {
	// move around options in selected fields list, supports single-select only
	var selected = getSelected();
	if (selected.length == 1) selected.insertAfter(selected.next());

	// works around IE7 bad behavior
	$("#selected_display_fields").focus();

	generateSelectedDisplayFieldsParameter();
	return false;
}
