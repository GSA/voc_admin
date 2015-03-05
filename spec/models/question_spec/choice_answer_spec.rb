# == Schema Information
#
# Table name: choice_answers
#
#  id                 :integer          not null, primary key
#  answer             :string(255)
#  choice_question_id :integer
#  answer_order       :integer
#  next_page_id       :integer
#  created_at         :datetime
#  updated_at         :datetime
#  clone_of_id        :integer
#  is_default         :boolean          default(FALSE)
#

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
