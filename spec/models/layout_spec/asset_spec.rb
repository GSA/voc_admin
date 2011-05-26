require 'spec_helper'

describe Asset do
	before(:each) do
		@valid_asset = Asset.new(:snippet => "test")
	end
	
	it "should be valid" do
		@valid_asset.should be_valid
	end
	
	it "is not valid without a presence (snippet)" do
		@valid_asset.snippet = nil
		@valid_asset.should_not be_valid
	end
	
  it "should clone it self" do
    survey_version = mock_model(SurveyVersion)
    page = mock_model(Page)
    pages = mock("Page collection", :find_by_clone_of_id=>page)
    survey_version.stub!(:pages).and_return(pages)
    @valid_asset.stub!(:survey_element).and_return(mock_model(SurveyElement, :attributes=>{}, :page_id=>1))
    @valid_asset.save!
    cloned_asset = @valid_asset.clone_me(survey_version)
    @valid_asset.snippet == cloned_asset.snippet
  end
end