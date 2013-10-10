class ChoiceAnswerReporter
  include Mongoid::Document

  field :ca_id, type: Integer
  field :text, type: String
  field :count, type: Integer, default: 0

  embedded_in :choice_question_reporter
  embeds_many :choice_answer_days
  index "choice_answer_days.date" => 1

  def add_day(date)
    day = choice_answer_days.find_or_create_by(date: date)
    day.inc(:count, 1)    
    inc(:count, 1)
  end

  def answer_percentage
    (count / choice_question_reporter.survey_version_responses.to_f) * 100
  end
end
