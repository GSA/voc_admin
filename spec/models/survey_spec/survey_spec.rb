require 'spec_helper'

describe Survey do
  before(:each) do
    @attr = {:name => "Test Survey", :description => "Survey used in RSpecs"}
  end
  
  it "should create a new survey given valid attributes" do
    Survey.create! @attr
  end
  
  it "should require a name" do
    no_name_survey = Survey.new :name => "", :description => "Survey used in RSpecs"
    no_name_survey.should_not be_valid
  end
  
  it "should require a description" do
    no_description_survey = Survey.new :name => "Test Survey", :description => ""
  end
  
  it "should reject duplicate names" do
    survey_1 = Survey.create! @attr
    survey_2 = Survey.new @attr
    survey_2.should_not be_valid
  end
  
  it "should create a major version on create" do
    survey = Survey.create! @attr
    survey.survey_versions.should_not be_empty
  end
  
  it "should create version 1.0 on survey create" do
    survey= Survey.create! @attr
    survey.survey_versions.first.version_number.should == "1.0"
  end
  
  it "should create version 2.0" do
    survey = Survey.create! @attr
    survey.create_new_major_version
    survey.survey_versions.order('major desc').first.version_number.should == "2.0"
  end
  
  it "should create a new minor version 1.1"
  
end