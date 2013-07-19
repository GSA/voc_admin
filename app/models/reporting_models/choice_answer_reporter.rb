class ChoiceAnswerReporter
  include Mongoid::Document

  field :ca_id, type: Integer
  
  field :text, type: String
  field :count, type: Integer, default: 0

  embedded_in :choice_question_reporter
end