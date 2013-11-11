class QuestionReporter
  include Mongoid::Document

  field :s_id, type: Integer    # Survey id
  field :sv_id, type: Integer   # Survey Version id
  field :se_id, type: Integer   # Survey Element id

  # Total number of SurveyResponses for this ChoiceQuestion with values
  field :answered, type: Integer, default: 0

  index "sv_id" => 1
  index "se_id" => 1

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
