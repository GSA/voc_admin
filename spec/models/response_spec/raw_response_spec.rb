require 'spec_helper'

describe RawResponse do
	before(:each) do
		@valid_raw_response = RawResponse.new(:client_id => 1, :answer => "test",
			:question_content => mock_model(QuestionContent), 
			:status_id => 1, 
			:survey_response => mock_model(SurveyResponse, :survey_version_id => 1)
    )
	end
	
	it "should be valid" do
		@valid_raw_response.should be_valid
	end
	
	it "is not valid without a presence (client_id)" do
		@valid_raw_response.client_id = nil
		@valid_raw_response.should_not be_valid
	end
	
	it "is not valid if the client id isn't unique in the scop of a question content" do
   @valid_raw_response.dup.save!
   @valid_raw_response.should_not be_valid
  end
	
	it "is valid if the client id isn't unique outside of the scope of a question content" do
   @valid_raw_response.dup.save!
   @valid_raw_response.question_content = mock_model(QuestionContent)
   @valid_raw_response.should be_valid
  end
	
	it "is not valid without an answer" do
   @valid_raw_response.answer = nil
   @valid_raw_response.should_not be_valid
  end
	
	it "is not valid without a question content" do
		@valid_raw_response.question_content = nil
		@valid_raw_response.should_not be_valid
	end
	
	it "is not valid without a status id" do
		@valid_raw_response.status_id = nil
		@valid_raw_response.should_not be_valid
	end
	
	it "is not valid unless status id is a number" do
		@valid_raw_response.status_id = ""
		@valid_raw_response.should_not be_valid
	end
	
	it "is not valid without a survey response" do
		@valid_raw_response.survey_response = nil
		@valid_raw_response.should_not be_valid
	end
end