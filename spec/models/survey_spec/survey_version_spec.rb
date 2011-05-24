require 'spec_helper'

describe SurveyVersion do
  before(:each) do 
    @survey = Survey.create! :name => "Test Survey", :description => "RSpec test survey"
  end
  
  it "should require a survey" do
    SurveyVersion.new(:major => 1, :minor => 0, :published => false, :notes => "").should_not be_valid
  end
  
  it "should require a major version number" do
    SurveyVersion.new(:minor => 0, :published => false, :notes => "", :survey => @survey).should_not be_valid
  end
  
  it "should require a minor version number" do
    SurveyVersion.new(:major => 1, :published => false, :notes => "", :survey => @survey).should_not be_valid
  end
  
  it "should have a unique version number" do
    @survey.survey_versions.new(:major => @survey.survey_versions.first.major, :minor => 0, :published => false, :notes => "").should_not be_valid
  end
  
  it "should set the version to published" do
    @survey.survey_versions.first.publish_me
    @survey.survey_versions.first.published.should == true
  end
  
  it "should return the next page number" do
    @survey.survey_versions.first.next_page_number.should == 1
  end
  
  it "should return the next element number" do
    @survey.survey_versions.first.next_element_number.should == 1
  end
  
  it "should reorder all survey elements" 
  
  it "should clone itself to create a new minor version"
end