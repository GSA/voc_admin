require "spec_helper"

describe ChoiceQuestion do
  before(:each) do
    @choice_question = ChoiceQuestion.new(:answer_type => "check")
    @qc = mock_model(QuestionContent, :questionable => @choice_question, :statement => "RSpec ChoiceQuestion")
    @qc.stub!(:attributes).and_return({:statement=>"RSpec ChoiceQuestion"})
    @choice_question.stub(:question_content).and_return(@qc)
  end
    
  it "should be valid" do
    @choice_question.should be_valid
  end
  
  it "should clone it self" do
    survey_version = mock(SurveyVersion)
    @choice_question.save!
    @choice_question.choice_answers.create!(:answer => "Test")
    QuestionContentObserver.instance.stub!(:after_create).and_return(true)
    clone_question = @choice_question.clone_me(survey_version)
    clone_question.clone_of_id.should == @choice_question.id
    clone_question.choice_answers.size.should == @choice_question.choice_answers.size
  end
  
  
end