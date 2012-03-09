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
  
  it "should create a new minor version with out source version specified" do
    survey = Survey.create! @attr
    survey.create_new_minor_version
    survey.survey_versions.should have(2).records
  end
  
  it "should create a new minor version with source version specified" do
    survey = Survey.create! @attr
    survey.create_new_minor_version(survey.survey_versions.first.id)
    survey.survey_versions.should have(2).records
  end

  it "should return the survey_version with the highest major and minor numbers" do
    s = Survey.create! @attr
    new_sv = s.create_new_major_version
    s.newest_version.should == new_sv
  end
  
end