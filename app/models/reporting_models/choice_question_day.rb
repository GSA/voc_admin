class ChoiceQuestionDay
  include Mongoid::Document

  field :date, type: Date
  field :answered, type: Integer, default: 0
  field :chosen, type: Integer, default: 0

  embedded_in :choice_question_reporter
end
