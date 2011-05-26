require 'spec_helper'

describe DisplayField do
  before(:each) do
    @display_field_text = DisplayFieldText.new(:name=>"Test", :display_order=>1, :survey_version => mock_model(SurveyVersion, :survey_responses => []))
    DisplayFieldObserver.instance.stub(:after_create).and_return(true)
  end
  
  it "should be valid" do
    @display_field_text.should be_valid
  end
  
  it "should not be valid without a name" do
    @display_field_text.name = nil
    @display_field_text.should_not be_valid
  end
  
  it "should not be valid without a display order" do
    @display_field_text.display_order = nil
    @display_field_text.should_not be_valid
  end
  
  it "should not be valid if it has the same name as another display field in the same survey version" do

    @display_field_text.dup.save!
    @display_field_text.should_not be_valid
  end
  
  it "should be valid if it has the same name as another display field in another survey version" do
    @display_field_text.dup.save!
    @display_field_text.survey_version = mock_model(SurveyVersion, :survey_resposnes => [])
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
  
  it "should set the type when m_type is set" do
    DisplayField.new(:model_type => "DisplayFieldText").type.should == "DisplayFieldText"
    
  end
  

end