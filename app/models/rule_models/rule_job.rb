class RuleJob
	@queue = :voc_rules

	include Resque::Plugins::Status

	def perform
		rule = Rule.find(options['id'])

		rule.apply_me_all
	end
end