require 'spec_helper'

describe QuestionContent do
  before(:each) do
    @valid_question_content = QuestionContent.new(:statement => "test")
  end
  
  it "should be valid with valid attributes" do
    @valid_question_content.should be_valid
  end
  
  it "is not valid without a presence (statement)" do
		@valid_question_content.statement = nil
		@valid_question_content.should_not be_valid
	end
end