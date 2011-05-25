require 'spec_helper'

describe TextQuestion do
  
  before(:each) do
    @text_question = TextQuestion.new(
      :answer_type => "area"
    )
    @text_question.question_content = mock_model(QuestionContent, :[]= => nil, :questionable => @text_question, :question_type => "TextQuestion", :id => 1)
  end
  
  it "should be valid" do
    @text_question.should be_valid
  end
  
  it "is not valid without a presence (answer_type)" do
		@text_question.answer_type = nil
		@text_question.should_not be_valid
	end
	
	it "is not valid without a presence (question_content)" do
    @text_question.question_content = nil
    @text_question.should_not be_valid
  end

  describe "check_condition testing" do
    before(:each) do
      @responses = [mock_model(RawResponse, :question_content_id => 1, :answer => "test answer")]
      @survey_response = mock_model(SurveyResponse, :raw_responses => @responses)
    end
    
    it "should return true when the values match and the conditional is '='" do
      condition = @text_question.check_condition(@survey_response, 1, "test answer")
      condition.should == true
    end
    
    it "should return false when the values match and the conditional is '='" do
      condition = @text_question.check_condition(@survey_response, 1, "wrong answer")
      condition.should == false
    end 
    
    it "should return true when the values do not match and the conditional is '!=' " do
      condition = @text_question.check_condition(@survey_response, 2, "wrong answer")
      condition.should == true    
    end
  
    it "should return false when the values do not match and the conditional is '!=' " do
      condition = @text_question.check_condition(@survey_response, 2, "test answer")
      condition.should == false    
    end    
  end

  
end