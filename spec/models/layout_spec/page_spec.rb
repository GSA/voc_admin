require 'spec_helper'

describe Page do
	before(:each) do
		@valid_page = Page.new(:page_number => 1,
		:survey_version => mock_model(SurveyVersion),
		:style_id => 1)
	end
	
	it "should be valid" do
		@valid_page.should be_valid
	end
	
	it "is not valid without a presence (page_number)" do
		@valid_page.page_number = nil
		@valid_page.should_not be_valid
	end
	
	it "is not valid unless page number is a number" do
		@valid_page.page_number = ""
		@valid_page.should_not be_valid
	end
	
	it "is not valid with the same page number in the scope of a survey version"

	it "is valid with the same page number outside of the scope of a survey version"
	
	it "is not valid without a survey version" do
		@valid_page.survey_version = nil
		@valid_page.should_not be_valid
	end
	
	it "is not valid without a survey_id" 
end