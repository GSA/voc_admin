namespace :resque do
	desc "Attempt to feed failed jobs back into Redis through Resque after Redis outage"
	task :rescue do
		log_file = File.join("log","resque_rescue.log")

		puts "Logging to: #{log_file}"

		$stdout = File.new(log_file, 'a')

		puts "--------------------------------------------------------------------------------"
		puts "Starting Resque rescue"
		puts ""

		#Load rails
		log_event("Starting Rails",3)
		require File.dirname(__FILE__) + "/../../config/application"
		Rails.application.require_environment!

		perform_resque
	end

	private
	def log_event(message, level = 2)
		level_text = ''
		case level
		when 1
			level_text = 'VERBOSE'
		when 2
			level_text = 'NOTICE'
		when 3
			level_text = 'DB'
		when 4
			level_text = 'WARNING'
		when 5
			level_text = '***ERROR'
		end
		puts "#{Time.now.to_s} - #{level_text}: " + message
		$stdout.flush
	end

	def perform_resque
		log_event("Starting rescue...")

		ResquedJob.all.each do |job|
			log_event("Attempting to queue ResquedJob ##{job.id} (for #{job.class_name}):")

			begin
				Resque.enqueue(job.class_name.constantize, *job.job_arguments)
				log_event("  Job successfully resqueued.")

				job.destroy
				log_event("  Job destroyed.")
			rescue
				log_event("  Job failed with error: #{$!.to_s}", 5)
			end

		end

		log_event("...finished rescue run.")
	end
end