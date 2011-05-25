require 'spec_helper'

describe MatrixQuestion do
  before(:each) do
    @valid_matrix_question = MatrixQuestion.new(:statement => "test")
  end
  
  it "should be valid with valid attributes" do
    @valid_matrix_question.should be_valid
  end
  
  it "is not valid without a presence (statement)" do
		@valid_matrix_question.statement = nil
		@valid_matrix_question.should_not be_valid
	end
	
  it "should clone itself" do
    survey_version = mock_model(SurveyVersion)
    @valid_matrix_question.save!
    choice_question = mock_model(ChoiceQuestion)
    clone_question = @valid_matrix_question.clone_me(survey_version)
    clone_question.statement.should == @valid_matrix_question.statement
    clone_question.clone_of_id.should == @valid_matrix_question.id
    clone_question.choice_questions.size.should == @valid_matrix_question.choice_questions.size
  end
  
  it "should clone its related choice questions" do
    survey_version = mock_model(SurveyVersion)
    choice_question = ChoiceQuestion.new(:answer_type => "check")
    qc = mock_model(QuestionContent, :questionable => choice_question, :statement => "RSpec ChoiceQuestion")
    qc.stub!(:attributes).and_return({:statement=>"RSpec ChoiceQuestion"})
    choice_question.stub(:question_content).and_return(qc)
    choice_question.save!
    @valid_matrix_question.choice_questions << choice_question
    @valid_matrix_question.save!
    clone_question = @valid_matrix_question.clone_me(survey_version)
    clone_question.choice_questions.size.should == @valid_matrix_question.choice_questions.size
  end

end