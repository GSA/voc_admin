require 'spec_helper'

describe MatrixQuestion do
  before(:each) do
    @matrix_question = MatrixQuestion.new(
      :rows => "row1\r\nrow2",
      :columns => "column1\r\ncolumn2",
      :question_content => mock_model(QuestionContent, :statement => "RSpec Question", :[]= => nil, :save => true),
      :survey_element => mock_model(SurveyElement, :[]= => nil)
    )
  end
  
  it "should be valid" do
    @matrix_question.should be_valid
  end
  
  it "should not be valid without at least one row" do
    @matrix_question.rows = nil
    @matrix_question.should_not be_valid
  end
  
  it "should not be valid without at least one column" do
    @matrix_question.columns = nil
    @matrix_question.should_not be_valid
  end
  
  it "should return an array of row headers" do
    @matrix_question.row_headers.should == ["row1", "row2"]
  end
  
  it "should return an array of column headers do" do
    @matrix_question.column_headers.should == ["column1", "column2"]
  end
  
  it "should not be valid without a question content" do
    @matrix_question.question_content = nil
    @matrix_question.should_not be_valid
  end
  
  it "should not be valid without a survey element" do
    @matrix_question.survey_element = nil
    @matrix_question.should_not be_valid
  end
  
  #   before(:each) do
  #     @choice_answers = [mock_model(ChoiceAnswer, :attributes=>{})]
  #     @choice_questions = [
  #       mock_model(ChoiceQuestion, :choice_answers => @choice_answers, :attributes=>{:answer_type=>"check"}, :question_content => mock_model(QuestionContent, :attributes=>{"statement"=>"Test"}, :statement => "Test")),
  #       mock_model(ChoiceQuestion, :choice_answers => @choice_answers, :attributes=>{:answer_type=>"check"}, :question_content => mock_model(QuestionContent, :attributes=>{"statement"=>"Test2"}, :statement => "Test2"))]
  #     @choice_questions.stub(:includes).and_return(@choice_questions)
  #     @valid_matrix_question = MatrixQuestion.new(:statement => "test")
  #     @valid_matrix_question.stub(:choice_questions).and_return(@choice_questions)
  #   end
  #   
  #   it "should be valid with valid attributes" do
  #     @valid_matrix_question.should be_valid
  #   end
  #   
  #   it "is not valid without a presence (statement)" do
  #   @valid_matrix_question.statement = nil
  #   @valid_matrix_question.should_not be_valid
  # end
  #   
  #   it "should clone it self" do
  #     page = mock_model(Page)
  #     clone_page =  mock_model(Page, :clone_of_id=>page.id)
  #     pages = mock("Page collection", :find_by_clone_of_id=>clone_page)
  #     survey_version = mock_model(SurveyVersion)
  #     survey_version.stub!(:pages).and_return(pages)
  #     choice_question = mock_model(
  #       ChoiceQuestion,
  #       :answer_type => "check",
  #       :question_content  => mock_model(QuestionContent, :statement => "RSpec MatrixQuestion - ChoiceQuestion") 
  #     )
  #     @valid_matrix_question.stub!(:survey_element).and_return(mock_model(SurveyElement, :attributes=>{}, :page_id=>page.id))  
  #     @valid_matrix_question.choice_questions = @choice_questions
  #     @valid_matrix_question.save!
  #     clone_question = @valid_matrix_question.clone_me(survey_version)
  #     
  #     
  #     clone_question.statement.should == @valid_matrix_question.statement
  #     clone_question.clone_of_id.should == @valid_matrix_question.id
  #     clone_question.choice_questions.size.should == @valid_matrix_question.choice_questions.size
  #   end

end