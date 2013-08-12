class ChoiceAnswerReporter
  include Mongoid::Document

  field :ca_id, type: Integer
  
  field :text, type: String
  field :count, type: Integer, default: 0

  embedded_in :choice_question_reporter

  def answer_percentage
  	(count / choice_question_reporter.survey_version_responses.to_f) * 100
  end
end