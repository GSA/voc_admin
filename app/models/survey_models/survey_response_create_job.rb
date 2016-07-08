class SurveyResponseCreateJob
  @queue = :voc_responses

  # Wrapper for Resque job worker
  def self.perform(response, survey_version_id, submitted_at = Time.now)
    SurveyResponse.process_response(response, survey_version_id, submitted_at)
  end
end
