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
    survey = Survey.create! :name => "test", :description => "rspec survey"
    version = survey.survey_versions.first

    DisplayFieldObserver.instance.should_receive(:after_create).and_return(true)
    
    display_field = DisplayFieldText.create!(
      :name => "Display Field",
      :display_order => 1,
      :survey_version => version
    )

    target_version = survey.create_new_major_version
    
    cloned_df = display_field.clone_me(target_version)
    cloned_df.should be_valid
    target_version.display_fields.should have(1).display_field
    cloned_df.name.should == display_field.name
    cloned_df.display_order.should == display_field.display_order
    cloned_df.survey_version.should_not be(version)
  end
  
  it "should set the type when model_type is set" do
    DisplayField.new(:model_type => "DisplayFieldText").type.should == "DisplayFieldText"
  end
  

end