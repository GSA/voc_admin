class RawResponsesController < ApplicationController
  def index
    @responses = params[:client_id].blank? ? RawResponse.all : RawResponse.where(:client_id => params[:client_id]).all
    
    respond_to do |format|
      format.html #
      format.js {render :partial => "response_table", :locals => {:obect => @responses}}
    end
  end
  
  def create
    @responses = {}
    params[:response].each do |index, response|
      @responses[index] = RawResponse.create response
    end
    redirect_to raw_responses_path
  end
end
