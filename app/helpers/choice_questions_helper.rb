# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# View helpers for ChoiceQuestion functionality.
module ChoiceQuestionsHelper

  # Generates options for the ChoiceQuestion type dropdown.
  # 
  # @param [Integer] default the id of the default selection.
  # @return [String] generated HTML option tags
  def options_for_answer_type(default)
    options_for_select([["Radio", ChoiceAnswer::RADIO], ["Dropdown", ChoiceAnswer::DROPDOWN], ["Multi-select", ChoiceAnswer::MULTISELECT], ["Check Boxes", ChoiceAnswer::CHECKBOX]], :selected => default)
  end

  # Generates options for the ChoiceQuestion orientation dropdown.
  # 
  # @param [Integer] default the id of the default selection.
  # @return [String] generated HTML option tags
  def options_for_answer_placement(default)
    options_for_select([["horizontal (side-by-side)", ChoiceQuestion::HORIZONTAL_PLACEMENT], ["vertical (stacked)", ChoiceQuestion::VERTICAL_PLACEMENT]], :selected => default)
  end

  # Determines whether the Auto Next Page option should be visible.
  # 
  # @param [ActionView::Helpers::FormBuilder] f the FormBuilder from the view
  # @param [ChoiceQuestion] choice_question the ChoiceQuestion to test against
  def auto_next_page_visibility(f, choice_question)
  	return initial_element_visibility(f.object.new_record?, choice_question, ChoiceAnswer::RADIO)
  end

  # Determines whether the Answer Placement option should be visible.
  # 
  # @param [ActionView::Helpers::FormBuilder] f the FormBuilder from the view
  # @param [ChoiceQuestion] choice_question the ChoiceQuestion to test against
  def answer_placement_visibility(f, choice_question)
  	return initial_element_visibility(f.object.new_record?, choice_question, ChoiceAnswer::RADIO, ChoiceAnswer::CHECKBOX)
  end

  # Allows conditional visibility of an element based on choice_question.answer type,
  # and/or some other arbitrary condition.
  #
  # @param [Boolean] cond evaluated boolean condition
  # @param [ChoiceQuestion] choice_question a ChoiceQuestion
  # @param [Array<Integer>] answer_types matching ChoiceAnswer type ids
  def initial_element_visibility(cond, choice_question, *answer_types)
  	return "style='display: none'" unless cond || answer_types.include?(choice_question.answer_type)
  end
end