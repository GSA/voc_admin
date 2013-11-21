require 'spec_helper'
include SurveyHelpers

describe SurveyVersionReporter do
  context "questions skipped and questions asked" do
    before do
      publish_survey_version
      build_three_simple_responses

      # create a survey response where not every question is answered
      @sr4 = build_survey_response @v, '104', { @q1 => "b" }, true
      SurveyVersionReporter.find_or_create_reporter(@v.id)
      @v.reporter.update_reporter!
    end

    it "should create survey version question counts" do
      @v.reporter.questions_asked.should == 12
      @v.reporter.questions_skipped.should == 2
    end
  end
end
