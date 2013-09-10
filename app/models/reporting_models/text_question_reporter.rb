class TextQuestionReporter < QuestionReporter

  field :tq_id, type: Integer    # TextQuestion id
  field :question, type: String

  # Words used in answers and their counts
  field :words, type: Hash, default: {}
end
