/**
 * @author jalvarado
 */

function add_fields(link, association, content){
	var new_id = new Date().getTime();
	var regexp = new RegExp("new_"+association, "g")
	$(link).before(content.replace(regexp, new_id));
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

});