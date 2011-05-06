class SurveyResponsesController < ApplicationController
  def index
    @survey_version_id = params[:survey_version_id].nil? ? nil : SurveyVersion.find(params[:survey_version_id])
    @survey_responses = SurveyResponse.where("survey_version_id = ?", @survey_version_id).where(:status_id => 4).order("created_at desc").page params[:page]
    
    respond_to do |format|
      format.html #
      format.js {render :partial => "survey_response_list", :locals => {:objects => @survey_responses, :version_id => @survey_version_id}}
    end
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
