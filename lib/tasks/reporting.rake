
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
    puts "Deleting all reporting collections first..."
    ChoiceQuestionReporter.all.delete

    errors = []

    survey_versions = SurveyVersion.all
    survey_version_count = survey_versions.count

    survey_versions.each_with_index do |survey_version, index|
      puts "Now processing SV #{survey_version.id}, #{index} of #{survey_version_count}..."

      survey = survey_version.survey
      display_fields = survey_version.display_fields.to_a

      print "\n  Choice questions:\n"
      survey_version.choice_questions.each do |choice_question|
        survey_element = choice_question.survey_element
        question_text = choice_question.question_content.statement
        choice_answers = choice_question.choice_answers.to_a

        display_field = display_fields.find { |df| df.name == question_text }

        if display_field
          print "\r    Importing CQID #{choice_question.id} / DFID #{display_field.id}..."

          display_field_values = display_field.display_field_values.to_a

          begin
            choice_question_reporter = ChoiceQuestionReporter.find_or_create_by(cq_id: choice_question.id)

            choice_question_reporter.s_id = survey.id
            choice_question_reporter.sv_id = survey_version.id
            choice_question_reporter.se_id = survey_element.id

            choice_question_reporter.question = question_text

            display_field_values.each do |display_field_value|
              raw_display_field_value = display_field_value.value

              answer_values = raw_display_field_value.try(:split, DisplayFieldValue::VALUE_DELIMITER)

              if answer_values.present?
                choice_question_reporter.inc(:responses, 1)
                
                permutations = choice_question_reporter.choice_permutation_reporters.find_or_create_by(values: raw_display_field_value)
                permutations.inc(:count, 1)

                answer_values.each do |answer_value|
                  answer = choice_question_reporter.choice_answer_reporters.find_or_create_by(text: answer_value)
                  answer.inc(:count, 1)

                  answer.ca_id = choice_answers.find { |ca| ca.answer == answer_value }.try(:id)
                end
              end
            end

          rescue Exception => e
            print "\rERROR: Failed import for #{choice_question.id};\n  Message: #{$!.to_s}\n  Backtrace: #{e.backtrace}\n"
            errors << [choice_question.id, $!.to_s, e.backtrace]
          end
        else
          print "\rERROR: Failed to find a matching DisplayField for ChoiceQuestion: #{choice_question.id}; text: #{question_text}\n"
          errors << [choice_question.id, "mismatch", choice_question.question_content.statement]
        end
      end

      print "\n...finished processing SV #{survey_version.id}.\n\n"
    end

    puts "...question import finished. #{errors.count} errors."

  end
end