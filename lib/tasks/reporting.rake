namespace :reporting do
  desc <<-EOS
  Export SurveyResponses created between <start_date> and <end_date>
  Dates must be formatted as YYYY-mm-dd
  EOS
  task :export_in_range, [:start_date_str, :end_date_str] => [:environment] do |t, args|
    TIMEZONE_STR = "Eastern Time (US & Canada)"
    DATE_FORMAT_REGEX = /\A\d{4}-\d{1,2}-\d{1,2}\z/
    USAGE = <<-EOS
      usage: rake reporting:export_in_range[<start_date>,<end_date>]

      start_date and end_date must be in the format YYYY-mm-dd and are inclusive dates.
    EOS

    raise USAGE if args.start_date_str.blank? || args.end_date_str.blank?

    start_date_str = args.start_date_str
    end_date_str = args.end_date_str

    raise "Start date must use format YYYY-mm-dd" unless start_date_str.match(DATE_FORMAT_REGEX)
    raise "End date must use format YYYY-mm-dd" unless end_date_str.match(DATE_FORMAT_REGEX)

    start_date = ActiveSupport::TimeZone[TIMEZONE_STR].parse(start_date_str)
    end_date = ActiveSupport::TimeZone[TIMEZONE_STR].parse(end_date_str).end_of_day

    survey_responses = SurveyResponse.where("created_at >= ? AND created_at <= ?", start_date, end_date)
    total_to_export = survey_responses.count

    puts "Exporting #{total_to_export} responses between #{start_date} and #{end_date} to MongoDB"

    total_exported = 0
    survey_responses.find_in_batches do |batch|
      batch.each(&:export_values_for_reporting)
      puts "exported #{total_exported += batch.size}/#{total_to_export}"
    end
  end

  desc "create csv with counts in root dir"
  task :csv_report, [:month, :year] => [:environment] do |t,args|
    MonthlyReport.new(args.month.to_i, args.year.to_i).generate
  end

  desc "create monthly reports for the last x months. [month, year, num_months]"
  task :monthly_reports, [:month, :year, :num_reports] => [:environment] do |t, args|
    month = args.month.to_i
    year = args.year.to_i
    num_reports = args.num_reports.to_i

    (num_reports).times do |n|
      y = year
      m = if n >= month
        y -= 1
        12 - (n - month)
      else
        month - n
      end

      puts "Generating Report for #{m}-#{y}"
      Rake::Task["reporting:csv_report"].reenable
      Rake::Task["reporting:csv_report"].invoke(m, y)
    end
  end

  desc "Run all daily reporting tasks - counts, loading questions, and mailing recurring reports"
  task :daily => [:environment] do
    puts "Updating survey version counts..."
    Rake::Task["reporting:update_survey_version_counts"].execute
    puts "  Finished updating survey version counts."
    puts "Loading question reporting DB..."
    Rake::Task["reporting:load_questions"].execute
    puts "  Finished loading question reporting DB."

    today = Date.today.strftime
    five_days_ago = (Date.today - 5).strftime
    puts "Re-exporting last 5 days..."
    Rake::Task["reporting:export_in_range"].invoke(five_days_ago, today)
    puts "  Finished re-exporting."

    puts "Mailing recurring reports..."
    Rake::Task["reporting:mail_recurring_reports"].execute
    puts "  Finished recurring reports."

    if ENV['SEND_ALARMS'].present?
      puts "Sending out alarm notifications for surveys..."
      Rake::Task["alarm:notifications"].execute
      puts " Finished sending alarm notifications"
    end

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
      sleep 10
    end

    puts "...export finished. #{errors} errors."
  end

  desc "Update ReportableSurveyResponses archived value"
  task :update_reportable_responses_archive => [:environment] do

    ct = 0
    sr_archived_arr = SurveyResponse.unscoped.where(:archived => true).select(:id).map(&:id)
    ReportableSurveyResponse.unscoped.all.each do |rr|
      begin
        if sr_archived_arr.include?(rr.survey_response_id)
          rr.archived = true
          ct += 1
        else
          rr.archived = "temp"
          rr.save!
          rr.archived = false
        end
        rr.save!
      rescue
        puts "  Error updating archive for survey responses - #{$!.to_s}"
      end
    end
    puts "Number of archived responses updated is #{ct}"
  end

  desc "Update question reporters"
  task :update_question_reporters => [:environment] do
    Report.all.each do |report|
      puts "Updating report #{report.id}"
      report.text_question_reporters.each(&:update_reporter!)
      report.choice_question_reporters.each(&:update_reporter!)
    end
  end
end
