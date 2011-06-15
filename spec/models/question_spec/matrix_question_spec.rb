require 'spec_helper'

describe MatrixQuestion do
  before(:each) do
    @survey = Survey.create! :name => "Rspec survey", :description => "RSpec test survey"
    @version = @survey.survey_versions.first
    @page = @version.pages.create! :page_number => 1
    
    @matrix_question = MatrixQuestion.new
    
    @matrix_question.build_survey_element :survey_version => @version, :element_order => 1, :page => @page
    
    @qc = @matrix_question.build_question_content :statement => "Matrix Question 1"
    @choice_question = @matrix_question.choice_questions.build
    
    @choice_question.build_question_content :statement => "Row 1"
    @choice_question.answer_type = 'radio'
    
    @choice_answer = @choice_question.choice_answers.build
    @choice_answer.answer = "Answer 1"

  end
  
  it "should be valid with valid attributes" do
    @matrix_question.should be_valid
  end
  
  it "should not be valid without a question content" do
    @matrix_question.question_content = nil
    @matrix_question.should_not be_valid
  end
  
  it "should clone it self" do

    @matrix_question.should be_valid
    @matrix_question.save!
    
    target_version = @survey.create_new_major_version
    target_version.pages.create! :page_number => 1, :clone_of_id => @page.id
    
    cloned_question = @matrix_question.clone_me(target_version)
    cloned_question.should_not be_nil
    cloned_question.survey_version.should == target_version
    cloned_question.choice_questions.should have(1).question
    cloned_question.choice_questions.first.statement.should == @choice_question.statement
    cloned_question.choice_questions.first.choice_answers.should have(1).answer
    cloned_question.choice_questions.first.choice_answers.first.answer.should == @choice_answer.answer
  end

end