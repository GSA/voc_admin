class ProcessRawSubmission
  def self.process(raw_submission_id, survey_version_id)
    client_id = SecureRandom.hex(64)
    raw_submission = RawSubmission.find raw_submission_id
    response = raw_submission.post['response']
    
    # Remove extraneous data from the response
    response.slice!('page_url', 'raw_responses_attributes', 'device')
    response['raw_responses_attributes'].try(:values).try(:each) {|rr| rr.slice!('question_content_id', 'answer')}

    survey_response = SurveyResponse.new({
        :client_id => client_id, 
        :survey_version_id => survey_version_id,
        :raw_submission_id => raw_submission_id
      }.merge(response)
    )

    ## Work around for associating the child raw responses with the survey_response
    survey_response.raw_responses.each do |raw_response|
      raw_response.client_id = client_id
      raw_response.survey_response = survey_response
    end

    survey_response.created_at = raw_submission.updated_at
    survey_response.save!

    survey_response.process_me 1
  end
  
  
end
