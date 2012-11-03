module ChoiceQuestionsHelper
  def options_for_answer_type(default)
    options_for_select([["Radio", ChoiceAnswer::RADIO], ["Dropdown", ChoiceAnswer::DROPDOWN], ["Multi-select", ChoiceAnswer::MULTISELECT], ["Check Boxes", ChoiceAnswer::CHECKBOX]], :selected => default)
  end
end