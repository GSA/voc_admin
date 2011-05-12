/**
 * @author jalvarado
 */

function add_fields(link, association, content){
	var new_id = new Date().getTime();
	var regexp = new RegExp("new_"+association, "g");
	$(link).parent().before(content.replace(regexp, new_id));
	$("#edit_rule").hide(); // IE 8 hack to 
	$("#edit_rule").show(); // IE 8 hack to fix adding fields overflowing the div
}

/* On DOM object load */
$(function(){
	$(".ActionTargetSelect").live('change', function(){
		if( $(this).val() != "" ){
			$(this).prev("input[type=hidden]").val("Response");
			$(this).next("input[type=text]").val('');
			$(this).siblings(".HiddenValueField").val($(this).val());

		} else {
			$(this).prev("input[type=hidden]").val("Text");
		}
	});
	
	$(".ActionManualValue").live('change', function(){
		$(this).next("input[type=hidden]").val($(this).val());
		$(this).prev(".ActionTargetSelect").val("");
	})
	
	$("#new_rule").bind('submit', function(){
		$("#new_rule .ActionManualValue").each(function(index){
			if($(this).val() != ""){
				$(this).next("input[type=hidden]").val($(this).val());
			}
		});
	});


	/* Reload the fields when editing */
	$(".ActionTargetSelect").each(function(index){
		if($(this).prev("input[type=hidden]").val() == "Response") {
			$(this).val($(this).siblings(".HiddenValueField").val());
		} else {
			$(this).next("input[type=text]").val($(this).siblings(".HiddenValueField").val());
		}
	})
});