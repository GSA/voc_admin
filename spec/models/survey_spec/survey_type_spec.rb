require 'spec_helper'

describe SurveyType do
	before(:each) do
		@valid_survey_type = SurveyType.new(:name => "test")
	end
	
	it "should be valid" do
		@valid_survey_type.should be_valid
	end
	
	it "is not valid without a presence (name)" do
		@valid_survey_type.name = nil
		@valid_survey_type.should_not be_valid
	end
	
	it "is not valid if less than 1 character" do
		@valid_survey_type.name = ""
		@valid_survey_type.should_not be_valid
	end
	
	it "is not valid if longer than 255 characters" do
		@valid_survey_type.name = "a"*256
		@valid_survey_type.should_not be_valid
	end
	
	it "is not valid if not unique" do
		@valid_survey_type.dup.save
		@valid_survey_type.should_not be_valid
	end

	it "should capitalize name" do
		@valid_survey_type.name_upcase.should == @valid_survey_type.name.capitalize
	end
end