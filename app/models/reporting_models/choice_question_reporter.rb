class ChoiceQuestionReporter
	include Mongoid::Document

	field :cq_id, type: Integer		# ChoiceQuestion id
	field :s_id, type: Integer		# Survey id
	field :sv_id, type: Integer		# Survey Version id
	field :se_id, type: Integer		# Survey Element id

	field :question, type: String

	# Total number of SurveyResponses for this ChoiceQuestion with values
	field :answered, type: Integer, default: 0

	embeds_many :choice_answer_reporters
	embeds_many :choice_permutation_reporters

	def unanswered
		survey_version_responses - answered
	end

	def percent_answered
		@answered ||= (responses / survey_version_responses.to_f) * 100
	end

	def percent_unanswered
		100 - percent_answered
	end

	private

	def survey
		@survey ||= Survey.find(s_id)
	end

	def survey_version
		@survey_version ||= SurveyVersion.find(sv_id)
	end

	def survey_version_responses
		@survey_version_responses = survey_version.survey_responses.count
	end

	def survey_element
		@survey_element ||= SurveyElement.find(se_id)
	end
end