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
    
    page = mock_model(Page)
    clone_page =  mock_model(Page, :clone_of_id=>page.id)
    pages = mock("Page collection", :find_by_clone_of_id=>clone_page)
    survey_version = mock_model(SurveyVersion)
    survey_version.stub!(:pages).and_return(pages)
    qc = mock_model(QuestionContent, :questionable => @choice_question, :statement => "RSpec ChoiceQuestion")
    qc.stub!(:attributes).and_return({:statement=>"RSpec ChoiceQuestion"})
    @choice_question.stub!(:survey_element).and_return(mock_model(SurveyElement, :attributes=>{}, :page_id=>page.id))
    @choice_question.question_content = nil #remove the qc so we can stub it instead
    @choice_question.stub(:question_content).and_return(qc)
    @choice_question.save!
    @choice_question.choice_answers.create!(:answer => "Test")
    QuestionContentObserver.instance.stub!(:after_create).and_return(true)
    clone_question = @choice_question.clone_me(survey_version)
    clone_question.clone_of_id.should == @choice_question.id
    clone_question.choice_answers.size.should == @choice_question.choice_answers.size
  end
  
  
end