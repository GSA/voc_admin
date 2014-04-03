namespace :alarm do
  desc "Run all daily reporting tasks - counts, loading questions, and mailing recurring reports"
  task :notifications => [:environment] do
    Survey.where(:alarm => true).each do |survey|
      sv = survey.published_version
      if sv
        if sv.survey_responses.created_between(1.day.ago, Time.now).count == 0
          AlarmMailer.alarm(survey.alarm_notification_email,survey.name).deliver
        end
      end
    end
  end
end