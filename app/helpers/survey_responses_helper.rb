module SurveyResponsesHelper
  def display_question_answer(response)
    return "<i>No Answer</i>".html_safe if response.nil?
    case response.question_content.questionable_type
    when "ChoiceQuestion"
      ChoiceAnswer.find(response.answer.to_i).answer
    when "TextQuestion"
      response.answer
    else
      ""
    end
  end
end
