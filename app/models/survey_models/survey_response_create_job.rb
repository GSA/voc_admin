class SurveyResponseCreateJob
  @queue = :voc_responses

  # Wrapper for Resque job worker
  def self.perform(raw_submission_id, survey_version_id)
    ProcessRawSubmission.process(raw_submission_id, survey_version_id)
  end
end