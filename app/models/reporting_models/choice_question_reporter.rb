class ChoiceQuestionReporter
	include Mongoid::Document

	# ChoiceQuestion id
	field :id, type: Integer

	# Total number of SurveyResponses for this ChoiceQuestion with values
	field :responses, type: Integer, default: 0

	# Total number of answers selected across SurveyResponses
	# (can be > responses if multi)
	field :total, type: Integer, default: 0

	field :answers, type: Hash
	# choice_question_reporter = ChoiceQuestionReporter.find(id)
	#
	# One of these two?
	# choice_question_reporter.inc("answers.#{answer.id}", 1)
	# ***OR***
	# choice_question_reporter.update({"$inc" => {"answers.#{answer.id}" => 1})
end