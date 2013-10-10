class ChoiceAnswerDay
  include Mongoid::Document

  embedded_in :choice_answer_reporter

  field :count, type: Integer, default: 0
end
