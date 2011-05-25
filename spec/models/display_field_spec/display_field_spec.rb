require 'spec_helper'

describe DisplayField do
  before(:each) do
    @display_field_text = DisplayFieldText.new(:name=>"Test", :display_order=>1)
    @display_field_text.stub(:survey_version).and_return(mock_model(SurveyVersion, :survey_responses=>[]))
  end
  
  it "should be valid" do
    @display_field_text.should be_valid
  end
  
  it "should clone it self" do
    survey_version = mock_model(SurveyVersion, :survey_responses=>[])
    @display_field_text.save!
    clone_df = @display_field_text.clone_me(survey_version)
    clone_df.name.should == @display_field_text.name
    clone_df.display_order.should == @display_field_text.display_order
    clone_df.clone_of_id.should == @display_field_text.id
    clone_df.survey_version_id.should == survey_version.id
  end
  

end