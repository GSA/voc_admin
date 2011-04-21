module SurveyResponsesHelper
  def display_question_answer(response)
    case response.question_content.questionable_type
    when "ChoiceQuestion"
      ChoiceAnswer.find(response.answer.to_i).answer
    when "TextQuestion"
      response.answer
    end
  end
end
