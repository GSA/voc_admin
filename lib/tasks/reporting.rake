
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
          sr.export_for_reporting
        rescue Exception => e
          print "\n    ...failed with error: #{$!.to_s}\n Backtrace: #{e.backtrace}"
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
    errors = 0

    survey_versions = SurveyVersion.all
    survey_version_count = survey_versions.count

    survey_versions.each_with_index do |survey_version, index|
      puts "Now processing SV #{survey_version.id}, #{index} of #{survey_version_count}..."

      display_fields = survey_version.display_fields.to_a

      print "\n  Choice questions:\n"
      survey_version.choice_questions.each do |choice_question|
        display_field = display_fields.find {|df| df.name == choice_question.question_content.statement}

        if display_field
          print "\r    Importing CQID #{choice_question.id} / DFID #{display_field.id}..."

          begin
            question_report = ChoiceQuestionReporter.find_or_create_by(id: choice_question.id)
            answers = {}

            # more work here, please

            question_report.answers = answers

            question_report.save
          rescue Exception => e
            print "\rERROR: Failed import for #{choice_question.id};\n  Message: #{$!.to_s}\n  Backtrace: #{e.backtrace}\n"
            errors += 1
          end
        else
          print "\rERROR: Failed to find a matching DisplayField for ChoiceQuestion: #{choice_question.id}; text: #{choice_question.question_content.statement}\n"
        end
      end

      print "\n...finished processing SV #{survey_version.id}.\n\n"
    end

    puts "...question import finished. #{errors} errors."
  end
end