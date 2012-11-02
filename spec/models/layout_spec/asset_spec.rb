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
    asset = Asset.new
    survey_version = mock_model SurveyVersion

    asset.stub(:survey_element).and_return mock_model(SurveyElement, :attributes => {})

    survey_version.stub_chain(:pages, :find_by_clone_of_id, :id).and_return 1

    Asset.should_receive(:create!).with({
      "snippet" => nil,
      "survey_element_attributes" => {
        :survey_version_id => survey_version.id,
        :page_id => 1
      }
    })

    asset.clone_me survey_version
  end
end