class ChoiceQuestionReporter
	include Mongoid::Document

	field :cq_id, type: Integer
	field :s_id, type: Integer
	field :sv_id, type: Integer
	field :se_id, type: Integer

	field :question, type: String

	# Total number of SurveyResponses for this ChoiceQuestion with values
	field :responses, type: Integer, default: 0

	embeds_many :choice_answer_reporters
	embeds_many :choice_permutation_reporters
end