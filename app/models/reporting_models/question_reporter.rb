class QuestionReporter
  include Mongoid::Document

  field :s_id, type: Integer    # Survey id
  field :sv_id, type: Integer   # Survey Version id
  field :se_id, type: Integer   # Survey Element id

  # Total number of SurveyResponses for this ChoiceQuestion with values
  field :answered, type: Integer, default: 0

  def generate_element_data(*args)
    nil.to_json
  end

  def allows_multiple_selection
    false
  end

  def type
    nil
  end

  def unanswered
    survey_version_responses - answered
  end

  def percent_answered
    @answered ||= (answered / survey_version_responses.to_f) * 100
  end

  def percent_unanswered
    100 - percent_answered
  end

  def self.generate_reporters(survey_version, errors = [])
    self.generate_choice_question_reporters(survey_version, errors)
    self.generate_text_question_reporters(survey_version, errors)
    errors
  end

  protected

  def survey
    @survey ||= Survey.find(s_id)
  end

  def survey_version
    @survey_version ||= SurveyVersion.find(sv_id)
  end

  def survey_version_responses
    @survey_version_responses = survey_version.survey_responses.count
  end

  def survey_element
    @survey_element ||= SurveyElement.find(se_id)
  end

  def generate_choice_question_reporters(survey_version, errors)
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

  def generate_text_question_reporters(survey_version, errors)
    print "\n  Text questions:\n"
    survey_version.text_questions.each do |text_question|
      print "\r    Importing TQID #{text_question.id}..."

      begin
        TextQuestionReporter.generate_reporter(survey_version, text_question)
      rescue Exception => e
        print "\rERROR: Failed import for TextQuestion #{text_question.id};\n  Message: #{$!.to_s}\n"
        errors << [text_question.id, $!.to_s, e.backtrace]
      end
    end
  end

  def self.set_common_fields(reporter, survey_version, question)
    reporter.s_id = survey_version.survey_id
    reporter.sv_id = survey_version.id
    reporter.se_id = question.survey_element.id
  end
end
