class SurveyResponsesController < ApplicationController
  def index
    @survey_responses = SurveyResponse.all
  end
  
  def create
    @client_id = SecureRandom.hex(64)
    @survey_version_id = params[:survey_version_id]
    
    @survey_response = SurveyResponse.new ({:client_id => @client_id, :survey_version_id => @survey_version_id}.merge(params[:response]))
    
    @survey_response.raw_responses.each {|r| r.client_id = @client_id}
    
    @survey_response.save!
    
    redirect_to survey_responses_path
  end

end
