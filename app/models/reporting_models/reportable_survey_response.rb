class ReportableSurveyResponse
	include Mongoid::Document

	field :survey_id, type: Integer
	field :survey_version_id, type: Integer

	field :answers, type: Array
end