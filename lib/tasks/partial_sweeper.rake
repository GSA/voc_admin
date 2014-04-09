namespace :partial_sweeper do
  desc "Cron Jobable - Sweeps all partial submissions that are more than an hour old."
  task :run => [:environment] do
    puts "Sweeping Partials..."
    Rake::Task["partial_sweeper:sweep"].execute
    puts "  Finished sweeping partials."
  end

  desc "Sweeps all partial submissions that are more than an hour old."
  task :sweep => [:environment] do
    RawSubmission.where("submitted = ? AND updated_at <= ?",false,60.minutes.ago).find_each do |raw_submission|
      raw_submission.submitted=true
      raw_submission.save
      resque_args = raw_submission.post[:response], raw_submission.survey_version_id
      begin
        Resque.enqueue(SurveyResponseCreateJob, *resque_args)
      rescue
        Rails.logger.error("Error queueing Resque job: #{$!.to_s}")
        ResquedJob.create(class_name: "SurveyResponseCreateJob", job_arguments: resque_args )
      end
    end
  end
end