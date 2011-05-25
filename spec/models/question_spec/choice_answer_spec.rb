require 'spec_helper'

describe ChoiceAnswer do
	before(:each) do
		@valid_choice_answer = ChoiceAnswer.new(:answer => "test")
	end
	
	it "should be valid" do
		@valid_choice_answer.should be_valid
	end
	
	it "is not valid without a presence (answer)" do
		@valid_choice_answer.answer = nil
		@valid_choice_answer.should_not be_valid
	end
	
	it "is not valid if less than 1 character (answer)" do
		@valid_choice_answer.answer = ""
		@valid_choice_answer.should_not be_valid
	end
	
	it "is not valid if longer than 255 characters (answer)" do
		@valid_choice_answer.answer = "a"*256
		@valid_choice_answer.should_not be_valid
	end
end