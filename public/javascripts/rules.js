function add_fields(link, association, content){
	var new_id = new Date().getTime();
	var regexp = new RegExp("new_"+association, "g");
	$(link).parent().before(content.replace(regexp, new_id));
	$("#edit_rule").hide(); // IE 8 hack to 
	$("#edit_rule").show(); // IE 8 hack to fix adding fields overflowing the div
}

function remove_fields(link) {
	$(link).prev("input[type=hidden]").val("1");
	$(link).parent().hide();
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
	});

	/* Switch the Rule type based on the radio buttons */
	$("input[name='rule[action_type]']").live("change", function() {
		$("#email_action, #db_actions").toggleClass("displayNone");
	});

    $("#email_action_rule").live('click', function(){
      $("#email_action").show();
      $("#destroy_email_action").val(false);
      $("#destroy_db_action").val(true);
      $("#db_actions").hide();
    });

    $("#db_action_rule").live('click', function(){
      $("#destroy_email_action").val(true);
      $("#email_action").hide();
      $("#db_actions").show();
      $("#destroy_db_action").val(false);
    });
});

function run_rule(rule_id, source){
	$(source).hide();
	$.ajax({url: "/rules/"+rule_id+"/do_now",
			success: function(data){
				//set waiting text
				$(source).after("<div>Please Wait</div>");
				
				//setup timer to check for response
				setTimeout(function(){check_run_rule(data, source)}, 5000);
			}});
}

function check_run_rule(job_id, source){
	$.ajax({url: "/rules/check_do_now?job_id="+job_id,
		success: function(data){
			//set waiting text
			if(data == "done"){
				$(source).next("div").remove();
				$(source).show();
			}
			else
			{
				setTimeout(function(){check_run_rule(job_id, source)}, 5000);
			}
		}});
}