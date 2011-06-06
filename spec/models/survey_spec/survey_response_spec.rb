require 'spec_helper'

describe SurveyResponse do
  
  before(:each) do
    @sr = SurveyResponse.new(
      :client_id => SecureRandom.hex(64),
      :survey_version => mock_model(SurveyVersion),
      :raw_responses => [mock_model(RawResponse)]
    )
  end
  
  it "should be valid" do
    @sr.should be_valid
  end
  
  it "should not be valid without a client_id" do
    @sr.client_id = nil
    @sr.should_not be_valid
  end
  
  it "should not be valid without a survey_version_id" do
    @sr.survey_version = nil
    @sr.should_not be_valid
  end
  
  it "should not be valid without at least one raw response" do
    @sr.raw_responses = []
    @sr.should_not be_valid
  end
  
  it "should return the next survey response to be processed"
  
  it "should process the raw responses for the survey_repsonse object"
	
end