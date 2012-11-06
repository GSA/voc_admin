module ChoiceQuestionsHelper
  def options_for_answer_type(default)
    options_for_select([["Radio", ChoiceAnswer::RADIO], ["Dropdown", ChoiceAnswer::DROPDOWN], ["Multi-select", ChoiceAnswer::MULTISELECT], ["Check Boxes", ChoiceAnswer::CHECKBOX]], :selected => default)
  end

  def options_for_answer_placement(default)
    options_for_select([["horizontal (side-by-side)", ChoiceQuestion::HORIZONTAL_PLACEMENT], ["vertical (stacked)", ChoiceQuestion::VERTICAL_PLACEMENT]], :selected => default)
  end

  def auto_next_page_visibility(f, choice_question)
  	return initial_element_visibility(f.object.new_record?, choice_question, ChoiceAnswer::RADIO)
  end

  def answer_placement_visibility(f, choice_question)
  	return initial_element_visibility(f.object.new_record?, choice_question, ChoiceAnswer::RADIO, ChoiceAnswer::CHECKBOX)
  end

  # allows conditional visibility of an element based on choice_question.answer type,
  # and/or some other arbitrary condition.
  def initial_element_visibility(cond, choice_question, *answer_types)
  	return "style='display: none'" unless cond || answer_types.include?(choice_question.answer_type)
  end
end