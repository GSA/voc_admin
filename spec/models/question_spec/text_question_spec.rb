require 'spec_helper'

describe TextQuestion do
  
  before(:each) do
    @text_question = TextQuestion.new(
      :answer_type => "area"
    )
    qc = mock_model(QuestionContent, :quesitonable => @text_question, :statement => "RSpec TextQuestion")
    @text_question.stub(:question_content).and_return(qc)
  end
  
  it "should be valid" do
    @text_question.should be_valid
  end
  
  it "is not valid without a presence (answer_type)" do
		@text_question.answer_type = nil
		@text_question.should_not be_valid
	end
	
	it "is not valid without a presence (question_content)" 
  
end