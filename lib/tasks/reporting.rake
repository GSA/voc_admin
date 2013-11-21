
namespace :reporting do
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

  private

  def set_common_question_fields(question, question_reporter, survey_version)
    question_reporter.s_id = survey_version.survey_id
    question_reporter.sv_id = survey_version.id
    question_reporter.se_id = question.survey_element.id
  end
end
