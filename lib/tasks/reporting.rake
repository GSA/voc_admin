namespace :reporting do
  desc "Run all daily reporting tasks - counts, loading questions, and mailing recurring reports"
  task :daily => [:environment] do
    puts "Updating survey version counts..."
    Rake::Task["reporting:update_survey_version_counts"].execute
    puts "  Finished updating survey version counts."
    puts "Loading question reporting DB..."
    Rake::Task["reporting:load_questions"].execute
    puts "  Finished loading question reporting DB."
    puts "Mailing recurring reports..."
    Rake::Task["reporting:mail_recurring_reports"].execute
    puts "  Finished recurring reports."
    puts "Sending out alarm notifications for surveys..."
    Rake::Task["alarm:notifications"].execute
    puts " Finished sending alarm notifications"
    puts "Sweeping Partials..."
    Rake::Task["partial_sweeper:sweep"].execute
    puts "  Finished sweeping partials."
  end

  desc "Update counts on survey version"
  task :update_survey_version_counts => [:environment] do
    SurveyVersion.locked.find_each do |sv|
      begin
        sv.update_counts
      rescue
        puts "  Error updating counts for survey version #{sv.id} - #{$!.to_s}"
      end
    end
  end

  desc "Mail recurring reports"
  task :mail_recurring_reports => [:environment] do
    RecurringReport.find_each do |rr|
      begin
        rr.mail_report
      rescue
        puts "  Error mailing recurring report #{rr.id} - #{$!.to_s}"
      end
    end
  end

  desc "Aggregate question data into the Mongo reporting schema"
  task :load_questions => [:environment] do
    SurveyVersionReporter.update_reporters
  end

  desc "Aggregate question data into the Mongo reporting schema after deleting existing reporters"
  task :reload_questions => [:environment] do
    puts "Deleting all reporting collections first..."
    SurveyVersionReporter.all.destroy
    Rake::Task["reporting:load_questions"].execute
  end

  # NOTE: you should run a few of these and then add an index to Mongo for
  # survey id, survey version id, and response ids
  desc "Push all once-plus-processed survey responses to NOSQL"
  task :export_all => [:environment] do

    criteria = SurveyResponse.processed

    # in case of failure / cancel, pick up where you left off:
    # criteria = criteria.where(survey_version_id: 76)

    total = criteria.count
    page_size = 500
    batches = (total / page_size.to_f).ceil
    errors = 0

    puts "Starting export for #{total} records in #{batches} batches of #{page_size}..."

    (1..batches).each do |num|
      num_in_batch = 1

      puts "  Starting batch #{num}..."

      criteria.page(num).per(page_size).each do |sr|
        print "\r    #{num}/#{batches} => #{num_in_batch}/#{page_size} Exporting SRID #{sr.id}..."

        begin
          sr.export_values_for_reporting
        rescue Exception => e
          print "\n    ...failed with error: #{$!.to_s}"
          errors += 1
        end

        num_in_batch += 1
      end

      print "\n  ...batch #{num} finished.\n"
    end

    puts "...export finished. #{errors} errors."
  end
end
