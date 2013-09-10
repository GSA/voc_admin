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

  def unanswered
    survey_version_responses - answered
  end

  def percent_answered
    @answered ||= (answered / survey_version_responses.to_f) * 100
  end

  def percent_unanswered
    100 - percent_answered
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
end
