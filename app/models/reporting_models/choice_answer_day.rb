class ChoiceAnswerDay
  include Mongoid::Document

  field :date, type: Date
  field :count, type: Integer, default: 0

  embedded_in :choice_answer_reporter
end
