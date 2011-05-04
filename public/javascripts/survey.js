function show_next_page(page){
	var unanswered_question = false;
	
	$("#page_"+page+" .required_question").each(function(index){
		/* Check required radio questions */
		if($(this).siblings("input[type=radio]").length > 0 && $(this).siblings("input[type=radio]:checked").length == 0){
			alert("Please complete all required questions.");
			unanswered_question = true;
			return false;
		}
		
		/* Check required select questions (dropdown and multiple select) */
		if($(this).siblings("select").length > 0 && $(this).siblings("select").val() == null){
			alert("Please compleate all required questions.");
			unanswered_question = true;
			return false;
		}
	});
	
	if (!unanswered_question){
		$("#page_"+page).hide();
		var next_page = $("#page_" + page + "_next_page").val();
		$("#page_"+ $("#page_"+page+"_next_page").val()).show();		
	}
}

function prev_page(page){
	$("#page_"+page).hide();
	$("#page_"+(page -1)).show();
}

function set_next_page(current_page, next_page) {
	$("#page_" + current_page + "_next_page").val(next_page);
}
