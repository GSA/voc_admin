class SurveyResponseCreateJob
  @queue = :voc_responses

  # Wrapper for Resque job worker
  def self.perform(response, survey_version_id)
    SurveyResponse.process_response(response, survey_version_id)
  end
end