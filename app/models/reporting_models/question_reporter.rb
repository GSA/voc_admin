class QuestionReporter
  include Mongoid::Document

  field :s_id, type: Integer    # Survey id
  field :sv_id, type: Integer   # Survey Version id
  field :se_id, type: Integer   # Survey Element id
  field :answered, type: Integer, default: 0 # Total number of responses
  field :counts_updated_at, type: DateTime

  index "sv_id" => 1
  index "se_id" => 1

  # Implement in subclass
  def generate_element_data(*args)
    nil.to_json
  end

  # Implement in subclass
  def allows_multiple_selection
    false
  end

  # Implement in subclass
  def type
    nil
  end

  def unanswered
    survey_version_responses - answered
  end

  def percent_answered
    @percent_answered ||= (answered / survey_version_responses.to_f) * 100
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

  def responses_to_add(question_content)
    responses = question_content.raw_responses.reorder('')
    if counts_updated_at.present?
      d = counts_updated_at.in_time_zone("Eastern Time (US & Canada)") - 2.days
      d = d.end_of_day
      responses = responses.where("created_at > ?", d)
    end
    responses
  end

  def begin_delete_date
    if counts_updated_at.present?
      d = counts_updated_at.in_time_zone("Eastern Time (US & Canada)") - 1.days
      d = d.to_date
    end
  end

  def self.generate_choice_question_reporters(survey_version, errors)
    print "\n  Choice questions:\n"
    survey_version.choice_questions.each do |choice_question|
      print "\r    Importing CQID #{choice_question.id}..."
      begin
        ChoiceQuestionReporter.generate_reporter(survey_version, choice_question)
      rescue Exception => e
        print "\rERROR: Failed import for ChoiceQuestion #{choice_question.id};\n  Message: #{$!.to_s}\n"
        errors << [choice_question.id, $!.to_s, e.backtrace]
      end
    end
  end

  def self.generate_text_question_reporters(survey_version, errors)
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
