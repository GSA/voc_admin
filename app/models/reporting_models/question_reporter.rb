class QuestionReporter
  include Mongoid::Document

  field :se_id, type: Integer   # Survey Element id
  field :qc_id, type: Integer   # QuestionContent id
  field :answered, type: Integer, default: 0 # Total number of responses
  field :counts_updated_at, type: DateTime
  field :questions_asked, type: Integer
  field :questions_skipped, type: Integer

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
    responses = question_content.raw_responses.not_archived.reorder('')
    if counts_updated_at.present?
      d = counts_updated_at.in_time_zone("Eastern Time (US & Canada)") - 2.days
      d = d.end_of_day
      responses = responses.where("raw_responses.created_at > ?", d)
    end
    responses
  end

  def begin_delete_date
    if counts_updated_at.present?
      d = counts_updated_at.in_time_zone("Eastern Time (US & Canada)") - 1.days
      d = d.to_date
    end
  end
end
