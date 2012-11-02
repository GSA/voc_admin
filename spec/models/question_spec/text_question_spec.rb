require 'spec_helper'

describe TextQuestion do
  before(:each) do
    @text_question = TextQuestion.new(
      :answer_type => "area"
    )
    @text_question.question_content = mock_model(QuestionContent, :[]= => nil, :questionable => @text_question, :questionable_type => "TextQuestion", :id => 1)
  end
  
  it "should be valid" do
    @text_question.should be_valid
  end
  
  it "is not valid without a presence (answer_type)" do
		@text_question.answer_type = nil
		@text_question.should_not be_valid
	end
	
	it "is not valid without a presence (question_content)" do
    @text_question.question_content = nil
    @text_question.should_not be_valid
  end

  describe "check_condition testing" do
    before(:each) do
      @responses = [mock_model(RawResponse, :question_content_id => 1, :answer => "test answer")]
      @survey_response = mock_model(SurveyResponse, :raw_responses => @responses)
    end
    
    it "should return true when the values match and the conditional is '='" do
      condition = @text_question.check_condition(@survey_response, 1, "test answer")
      condition.should == true
    end
    
    it "should return false when the values match and the conditional is '='" do
      condition = @text_question.check_condition(@survey_response, 1, "wrong answer")
      condition.should == false
    end 
    
    it "should return true when the values do not match and the conditional is '!=' " do
      condition = @text_question.check_condition(@survey_response, 2, "wrong answer")
      condition.should == true    
    end
  
    it "should return false when the values do not match and the conditional is '!=' " do
      condition = @text_question.check_condition(@survey_response, 2, "test answer")
      condition.should == false    
    end    
  end

  it "should clone it self" do
    QuestionContentObserver.instance.stub!(:after_create).and_return(true)
    target_sv = mock_model(SurveyVersion)
    @text_question.build_question_content({ :required => false, :flow_control => false, :statement => "Rspec Question Content Statement"})
    @text_question.save!

    @text_question.stub_chain(:survey_element, :attributes).and_return({
      "page_id" => 1,
      "element_order" => 1,
      "survey_version_id" => 1,
      "assetable_type" => "TextQuestion",
      "assetable_id" => @text_question.id
    })

    @text_question.stub_chain(:survey_element, :page_id).and_return(1)

    target_sv.stub_chain(:pages, :find_by_clone_of_id, :id).and_return 2

    TextQuestion.any_instance.stub(:save!)

    cloned_question = @text_question.clone_me(target_sv)

    cloned_question.attributes.except("created_at", "updated_at", "id", "clone_of_id").should == @text_question.attributes.except("created_at", "updated_at", "id", "clone_of_id")
    cloned_question.question_content.attributes.except("questionable_id", "created_at", "updated_at", "id").should == @text_question.question_content.attributes.except("questionable_id", "created_at", "updated_at", "id")
    cloned_question.survey_element.attributes.except("page_id", "created_at", "updated_at", "id", "survey_version_id").should == @text_question.survey_element.attributes.except("page_id", "created_at", "updated_at", "id", "survey_version_id")

  end

  it "should set the clone_of_id"

  
  
end