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
end