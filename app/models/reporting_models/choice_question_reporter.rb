class ChoiceQuestionReporter < QuestionReporter

	field :cq_id, type: Integer		# ChoiceQuestion id
	field :question, type: String

	# Total number of SurveyResponses for this ChoiceQuestion with values
	field :answered, type: Integer, default: 0

	# Total number of Answers chosen across ChoiceQuestion responses;
	# used for simple average count of number of responses (for multiselect)
	field :chosen, type: Integer, default: 0

	embeds_many :choice_answer_reporters
	embeds_many :choice_permutation_reporters

	def unanswered
		survey_version_responses - answered
	end

	def percent_answered
		@answered ||= (answered / survey_version_responses.to_f) * 100
	end

	def percent_unanswered
		100 - percent_answered
	end

	# average number of chosen Answer options across all answered questions
	def average_answers_chosen(precision = 1)
		(chosen / answered.to_f).round(precision)
	end

	def top_permutations(number = 10)
		choice_permutation_reporters.desc(:count).limit(number).map(&:permutation)
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