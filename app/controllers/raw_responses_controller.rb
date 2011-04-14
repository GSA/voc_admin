class RawResponsesController < ApplicationController
  def create
    @responses = {}
    params[:response].each do |index, response|
      @responses[index] = RawResponse.create response
    end
  end
end
