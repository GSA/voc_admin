$(function() {
	// iframe: if a page url isn't passed in on the query string, grab parent referrer.
	var page_url = $("#response_page_url");
	if (page_url.val() == "" && parent) {
		page_url.val(parent.document.location.origin + parent.document.location.pathname);
	}
});

function show_next_page(page){
	var required_unanswered = false;

	required_unanswered = check_for_unanswered_required(page);

	if (!required_unanswered){
		$("#page_" + page).hide();
		var next_page = $("#page_" + page + "_next_page").val();

    /* Set the prev page on next page */
   set_prev_page(page, next_page);

		$("#page_"+ next_page).show();
		window.location.hash="PAGE_" + next_page;
	} else {
		alert(survey_required_fields_error);
	}

}

function show_prev_page(page){
	$("#page_"+page).hide();
	$("#page_"+ $("#page_" + page + "_prev_page").val() ).show();
	window.location.hash = "PAGE_" + page;
}

function set_next_page(current_page, next_page) {
	$("#page_" + current_page + "_next_page").val(next_page);
	$("#page_" + next_page + "_prev_page").val(current_page);
}

function set_prev_page(current_page, prev_page) {
	$("#page_" + prev_page + "_prev_page").val(current_page);
}

function check_for_unanswered_required(page) {
	required = false;
		$("#page_"+page+" input[type=hidden].required_question").each(function(index){
			if($(this).val() == 'true'){
				question_number = $(this).attr('id').split('_')[1]; // q_{number}_required
				/* if the element is a radio button that is required then check to make sure one is checked */
				if( $(".question_" + question_number + "_answer").attr('type') == "radio" && $(".question_" + question_number + "_answer:checked").length == 0 ) {
					required =  true;
				} else if( $("select.question_" + question_number + "_answer").length > 0 && $("select.question_" + question_number + "_answer").val() == "" ) {
					required =  true;
				} else if( $(".question_" + question_number + "_answer").attr('type') == "checkbox" && $(".question_" + question_number + "_answer").length > 0 && $(".question_" + question_number + "_answer:checked").length == 0 ) {
					required =  true;
				} else if( $(".question_" + question_number + "_answer").attr('type') == "text" && $(".question_" + question_number + "_answer").val() == "") {
					required =  true;
				} else if( $(".question_" + question_number + "_answer").prop('tagName').toLowerCase() == "textarea" && $(".question_" + question_number + "_answer").val() == "") {
					required =  true;
				}
			}
		});
		return required;
}

function validate_before_submit(page){
	if (!check_for_unanswered_required(page)){
		return true;
	} else {
		alert(survey_required_fields_error);
		return false;
	}

}