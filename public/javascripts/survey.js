function show_next_page(page){
	var required_unanswered = false;
	
	$("#page_"+page+" input[type=hidden].required_question").each(function(index){
		if($(this).val() == 'true'){
			/* if the element is a radio button that is required then check to make sure one is checked */
			if( $(this).siblings("input[type=radio]").length > 0 && $(this).siblings("input[type=radio]:checked").length  == 0){
				required_unanswered = true;
			} else if( $(this).siblings("select").length > 0 && $(this).siblings("select").val() == ""){
				required_unanswered = true;
			} else if( $(this).siblings("input[type=text]").length > 0 && !$(this).siblings("input[type=text]").first().val()) {
				required_unanswered = true;
			} else if( $(this).siblings("textarea").length > 0 && !$(this).siblings("textarea").first().val()) {
				required_unanswered = true;
			} 
		}
	});
	
	if (!required_unanswered){
		$("#page_" + page).hide();
		var next_page = $("#page_" + page + "_next_page").val();
		$("#page_"+ $("#page_"+page+"_next_page").val()).show();	
	} else {
		alert('Please answer all required questions before moving on to the next page.');
	}

}

function show_prev_page(page){
	$("#page_"+page).hide();
	$("#page_"+ $("#page_" + page + "_prev_page").val() ).show();
}

function set_next_page(current_page, next_page) {
	$("#page_" + current_page + "_next_page").val(next_page);
	$("#page_" + next_page + "_prev_page").val(current_page);
}

function set_prev_page(current_page, prev_page) {
	$("#page_" + prev_page + "_prev_page").val(current_page);
}
