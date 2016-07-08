$(function(){
  /* NextPage should submit an ajax update for the page to set the next_page_id */
  $(document).on("change", ".NextPageSelect", function() {
    toggleSpinner();
    $.ajax({
      type: "PUT",
      url: $(this).data("url"),
      data: "&page[next_page_id]=" + $(this).val()
    });
  });

  $("#overlay_container").on("click", "span.page_mngmnt a.deleteLink", function(e) {
    if($(this).data("flowControlTarget") == true ) {
      alert("Cannot delete page. Page is target of flow control. Remove flow control targeting this page before deleting.");
      e.preventDefault();
      return false;
    }
  });


  /* Selecting the checkbox to enable flow control at the page level should remove the disabled flag from the select box
   * Unchecking the box should disable the select menu and clear the next_page_id from the page model
   * 4/22/2013 - Dead code branch?
   */
   $(document).on("change", ".page_level_flow_control", function() {
    if( $(this).attr('checked') == true ) {
      /* The checkbox is checked and the select box shoudl be enabled */
      $(this).prev(".NextPageSelect").attr('disabled', null);
    } else {
      $(this).prev(".NextPageSelect").attr('disabled', 'disabled');
      toggleSpinner();
      $.ajax({
        type: "PUT",
        url: $(this).prev(".NextPageSelect").data("url"),
        data: "&page[next_page_id]="
      });
    } /* End else statement */
  });

  /* Functions for managing the select boxes for page and next_page
   * for multiple choice questions.
   */
  $(document).on("change", "#flow_control_checkbox", function() {
    var width = 0;
    /* If checkbox is selected then hide the next page dropdown for answers. */
    if(!$(this).is(':checked')){
      $(".next_pages").hide();
      $("#auto_next_page_fields").hide();
      width =  $("#edit_modal").width() - $(".next_pages:first").width();
    } else {
      /* Checkbox has been checked so show the page selections */
      $(".next_pages").show();
      if($("#choice_question_answer_type").val() == "radio"){
        $("#auto_next_page_fields").show()
      }

      width = $("#edit_modal").width() + $(".next_pages:first").width();
    }
    resizeModal($("#edit_modal").height(), width);
  });

  /*
   * When a page is chosen from the page selection for the question, remove that option
   * from the flow control page select dropdown.
   */
  // TODO: Implement this

  $(".next_page_select").each(function(index){
    $(this).val($("#choice_question_survey_element_attributes_page_id option:selected").next('option').val());
  });

  $("#choice_question_survey_element_attributes_page_id").bind('change', function(){
    $(".next_page_select").val($("#choice_question_survey_element_attributes_page_id option:selected").next('option').val());
  });

  /* Show the spinner on ajax requests to reorder elements/pages */
  $(document).on("ajax:beforeSend", ".element_order_up, .move_page_up, .element_order_down, .move_page_down, .link_to_new_page, .remove_page_link, .remove_question_link, .copy_page", function(){
    toggleSpinner();
  });

  /* When the Choice Question Type is Radio then the auto_next_page option should show up */
  /* When Radio or Checkbox, the Answer Placement option should show */
  $(document).on('change', "#choice_question_answer_type", function() {
    val = $(this).val();

    if (val == "radio") {
      $("#auto_next_page_fields").show();
      $("#answer_placement_fields").show();
    } else {
      $("#auto_next_page_fields").hide();
      if (val == "checkbox") {
        $("#answer_placement_fields").show();
      } else {
        $("#answer_placement_fields").hide();
      }
    }
  });

}); // End onLoad function

function toggleSpinner() {
  $("#spinner_overlay").toggle();
}

function remove_fields(link) {
    console.log(link);
    $(link).siblings('input[type=hidden][name*="_destroy"]').val(1);
  $(link).parent().hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  $(link).parent().prev().after(content.replace(regexp, new_id));
  if (association == "choice_answers" || association == "choice_questions") {
    if($("#flow_control_checkbox").is(':checked')){
      $(".next_pages").show();
    }

    // This is for survey_builder only
    resizeModal($("#edit_modal").height(), Math.max($("#edit_modal").width(), $(".simplemodal-container").width()));
  }
}

function add_matrix_answers(link, content){
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_matrix_answer", "g");
  $(link).parent().before(content.replace(regexp, new_id));

  resizeModal($("#edit_modal").height(), Math.max($("#edit_modal").width(), $(".simplemodal-container").width()));
}

function remove_matrix_answer(link){
  $(link).parent().remove();
  resizeModal($("#edit_modal").height(), $("#edit_modal").width());
}

function resizeModal(height, width){
  $(".simplemodal-container").css("height", height).css("width", width);
  $.modal.setPosition();
}

function swapMatrixQuestion(link, direction) {
  var current_field = $(link).siblings('textarea').first();
  var previous_field = null;

  if(direction == "up"){
    previous_field = $(link).parent().prevAll('div.ChoiceQuestionContent').first().children('textarea').first();
  } else {
    previous_field = $(link).parent().nextAll('div.ChoiceQuestionContent').first().children('textarea').first();
  }
  if(previous_field.length){
    var current_field_value = current_field.val();
    current_field.val(previous_field.val());
    previous_field.val(current_field_value);

  }
}

function swapAnswers(link, direction){
  var current_field = $(link).siblings('input:text').first();
  var previous_field = null;
  if(direction == "up"){
    previous_field = $(link).parent().prevAll('p.answer_fields').first().children('input:text').first();
  } else {
    previous_field = $(link).parent().nextAll('p.answer_fields').first().children('input:text').first();
  }


  if(previous_field.length){
    var current_field_value = current_field.val();
    current_field.val(previous_field.val());
    previous_field.val(current_field_value);

  }
}
