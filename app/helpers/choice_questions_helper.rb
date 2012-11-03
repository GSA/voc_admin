module ChoiceQuestionsHelper
  def options_for_answer_type(default)
    options_for_select([["Radio", ChoiceAnswer::RADIO], ["Dropdown", ChoiceAnswer::DROPDOWN], ["Multi-select", ChoiceAnswer::MULTISELECT], ["Check Boxes", ChoiceAnswer::CHECKBOX]], :selected => default)
  end

  def options_for_answer_placement(default)
    options_for_select([["horizontal (side-by-side)", ChoiceQuestion::HORIZONTAL_PLACEMENT], ["vertical (stacked)", ChoiceQuestion::VERTICAL_PLACEMENT]], :selected => default)
  end
end