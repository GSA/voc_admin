class SurveyVersionDay
  include Mongoid::Document

  field :date, type: Date
  field :questions_asked, type: Integer
  field :questions_skipped, type: Integer

  embedded_in :survey_version_reporter
end
