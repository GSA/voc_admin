function next_page(page){
	$("#page_"+page).hide();
	$("#page_"+ (page + 1)).show();
	return false;
}

function prev_page(page){
	$("#page_"+page).hide();
	$("#page_"+(page -1)).show();
	return false;
}