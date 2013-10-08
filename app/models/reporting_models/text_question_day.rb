class TextQuestionDay
  include Mongoid::Document

  field :date, type: Date

  # Words used in answers and their counts
  field :words, type: Hash, default: {}
  # Total number of SurveyResponses for this day with values
  field :answered, type: Integer, default: 0

  embedded_in :text_question_reporter
end
