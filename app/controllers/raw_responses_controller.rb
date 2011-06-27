class RawResponsesController < ApplicationController
  def index
   client_id = params[:client_id]
    @responses = client_id.blank? ? RawResponse.all : RawResponse.where(:client_id => client_id).all
    
    respond_to do |format|
      format.html #
      format.js {render :partial => "response_table", :locals => {:obect => @responses}}
    end
  end
  
  
  # TODO: Is this action used anymore?  Or all raw responses created through the survey response controller
  def create
    @responses = {}
    params[:response].each { |index, response| @responses[index] = RawResponse.create response }
    redirect_to raw_responses_path
  end
end