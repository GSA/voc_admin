class QuestionReporter
	include Mongoid::Document

	field :s_id, type: Integer		# Survey id
	field :sv_id, type: Integer		# Survey Version id
	field :se_id, type: Integer		# Survey Element id
end