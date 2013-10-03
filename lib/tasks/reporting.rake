
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
    puts "Deleting all reporting collections first..."
    ChoiceQuestionReporter.all.delete
    TextQuestionReporter.all.delete

    errors = []

    survey_versions = SurveyVersion.all
    survey_version_count = survey_versions.count

    survey_versions.each_with_index do |survey_version, index|
      puts "Now processing SV #{survey_version.id}, #{index} of #{survey_version_count}..."

      load_choice_questions(survey_version, errors)
      load_text_questions(survey_version, errors)

      print "\n...finished processing SV #{survey_version.id}.\n"
    end

    puts "...question import finished. #{errors.count} errors."

  end

  private

  def load_choice_questions(survey_version, errors)
    display_fields = survey_version.display_fields.to_a

    print "\n  Choice questions:\n"
    survey_version.choice_questions.each do |choice_question|
      question_text = choice_question.question_content.statement
      choice_answers = choice_question.choice_answers.to_a

      display_field = display_fields.find { |df| df.name == question_text }

      if display_field
        print "\r    Importing CQID #{choice_question.id} / DFID #{display_field.id}..."

        display_field_values = display_field.display_field_values.to_a

        begin
          choice_question_reporter = ChoiceQuestionReporter.create!(cq_id: choice_question.id)

          # initialize all answers with zero counts
          choice_answers.each do |ca|
            choice_question_reporter.choice_answer_reporters.create!(text: ca.answer, count: 0)
          end

          set_common_question_fields(choice_question, choice_question_reporter, survey_version)
          choice_question_reporter.question = question_text

          display_field_values.each do |display_field_value|
            raw_display_field_value = display_field_value.value

            answer_values = raw_display_field_value.try(:split, DisplayFieldValue::VALUE_DELIMITER)

            if answer_values.present?
              choice_question_reporter.inc(:answered, 1)
              choice_question_reporter.inc(:chosen, answer_values.count)
              
              permutations = choice_question_reporter.choice_permutation_reporters.find_or_create_by(values: raw_display_field_value)
              permutations.inc(:count, 1)

              permutations.save

              answer_values.each do |answer_value|
                answer = choice_question_reporter.choice_answer_reporters.find_or_create_by(text: answer_value)
                answer.inc(:count, 1)

                answer.ca_id = choice_answers.find { |ca| ca.answer == answer_value }.try(:id)

                answer.save
              end
            end
          end

          choice_question_reporter.save

        rescue Exception => e
          print "\rERROR: Failed import for ChoiceQuestion #{choice_question.id};\n  Message: #{$!.to_s}\n"
          errors << [choice_question.id, $!.to_s, e.backtrace]
        end
      else
        print "\rERROR: Failed to find a matching DisplayField for ChoiceQuestion: #{choice_question.id}; text: #{question_text}\n"
        errors << [choice_question.id, "mismatch", choice_question.question_content.statement]
      end
    end
  end

  def load_text_questions(survey_version, errors)
    print "\n  Text questions:\n"
    survey_version.text_questions.each do |text_question|
      print "\r    Importing TQID #{text_question.id}..."

      begin
        text_question_reporter = TextQuestionReporter.find_or_create_by(tq_id: text_question.id)
        set_common_question_fields(text_question, text_question_reporter, survey_version)
        question_content = text_question.question_content
        text_question_reporter.question = question_content.statement

        question_content.raw_responses.each do |raw_response|
          answer_values = raw_response.answer.try(:scan, /[\w'-]+/)

          if answer_values.present?
            text_question_reporter.inc(:answered, 1)

            answer_values.uniq.each do |answer_value|
              word = answer_value.downcase
              count = text_question_reporter.words[word] || 0
              text_question_reporter.words[word] = count + 1
            end
          end
        end
        text_question_reporter.exclude_common_words!
        text_question_reporter.populate_top_words!
        text_question_reporter.save

      rescue Exception => e
        print "\rERROR: Failed import for TextQuestion #{text_question.id};\n  Message: #{$!.to_s}\n"
        errors << [text_question.id, $!.to_s, e.backtrace]
      end
    end
  end

  def set_common_question_fields(question, question_reporter, survey_version)
    question_reporter.s_id = survey_version.survey_id
    question_reporter.sv_id = survey_version.id
    question_reporter.se_id = question.survey_element.id
  end

  def count_skips(survey_version, errors)
    begin
      pages = pages_for_survey_version(survey_version)
      first_page = pages.values.detect {|page| page[:page_number] == 1}.try(:[], :page_id)
      skip = 0
      total = 0
      survey_version.survey_responses.each do |sr|
        raw_responses = Hash[sr.raw_responses.map {|rr| [rr.question_content_id, rr]}]
        next_page = first_page
        while next_page do
          page = pages[next_page]
          next_page = page[:next_page_id]
          page[:questions].each do |question|
            total += 1
            rr = raw_responses[question[:qc_id]]
            if rr.present?
              if question[:flow_control] && question[:flow_map][rr.answer].present?
                next_page = question[:flow_map][rr.answer]
              end
            else
              skip += 1
            end
          end
        end
      end
    rescue Exception => e
      print "\rERROR: Failed skip counting for Survey Version #{survey_version.id};\n  Message: #{$!.to_s}\n"
      errors << [survey_version.id, $!.to_s, e.backtrace]
    end
  end

  # generates an array of page data that looks like
  # {
  #   :page_id => 345,
  #   :next_page_id => 346,
  #   :questions => [
  #     {
  #       :qc_id => 730,
  #       :flow_control => true,
  #       :flow_map => { "2013" => 346, "2014" => 348 }
  #     }
  #   ]
  # }
  def pages_for_survey_version(survey_version)
    pages = {}
    survey_version.pages.each do |page|
      questions = []
      page.survey_elements.questions.each do |element|
        element.assetable.reload # for some reason this is necessary to get some question content
        if element.assetable_type == "MatrixQuestion"
          element.assetable.choice_questions.each {|cq| questions << question_hash(cq)}
        else
          questions << question_hash(element.assetable)
        end
      end
      pages[page.id] = {page_id: page.id, page_number: page.page_number, next_page_id: page.next_page.try(:id), questions: questions}
    end
    pages
  end

  # hash of question used by pages_for_survey_version
  def question_hash(question)
    qc = question.question_content
    hash = {qc_id: qc.id, flow_control: qc.flow_control?}
    if qc.flow_control?
      hash[:flow_map] = Hash[question.choice_answers.map {|ca| [ca.id.to_s, ca.next_page_id]}]
    end
    hash
  end
end
