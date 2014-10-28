class SurveyResponseCreateJob
  @queue = :voc_responses

  # Wrapper for Resque job worker
  def self.perform(raw_submission_id, survey_version_id)
    if raw_submission_id.is_a? Hash
      SurveyResponse.process_response(raw_submission_id, survey_version_id)
    else
      ProcessRawSubmission.process(raw_submission_id, survey_version_id)
    end
  end
end