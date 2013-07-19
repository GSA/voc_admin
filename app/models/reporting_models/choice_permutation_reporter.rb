class ChoicePermutationReporter
  include Mongoid::Document

  field :values, type: String
  field :count, type: Integer, default: 0

  embedded_in :choice_question_reporter
end