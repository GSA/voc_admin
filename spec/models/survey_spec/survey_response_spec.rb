require 'spec_helper'

describe SurveyResponse do
  before(:each) do
    @sr = SurveyResponse.new(
      :survey_version => mock_model(SurveyVersion),
      :display_field_values => [mock_model(DisplayFieldValue, :[]= => true, :save => true, :value => 'test')]
    )
  end
  
  it "should be valid" do
    @sr.should be_valid
  end
  
  it "should not be valid without a survey version" do
    @sr.survey_version = nil
    @sr.should_not be_valid
  end
  
  it "should get the next response from the new responses table"
  
  it "should add an entry to the new responses table after creation" do
    @sr.save!
    
    NewResponse.all.should have(1).response
  end
  
  it "should call queue_response when a response is created" do
    @sr.should_receive(:queue_for_processing).once.and_return(true)
    @sr.save!
  end
  
  it "should return all survey responses with a display field value like the provided search text" do
    survey = create :survey
    version = survey.survey_versions.first
    page = version.pages.create! :page_number => 1
    question = TextQuestion.new
    question.build_question_content :statement => "text Question"
    question.build_survey_element :survey_version => version, :element_order => 1
    question.answer_type = 'field'
    question.save!
    
    sr = SurveyResponse.new :survey_version_id => version.id, :client_id => '123', :status_id => 1, :worker_name => nil
    sr.raw_responses.build :client_id => '123', :answer => "test", :question_content => question.question_content, :status_id => 1, :survey_response => sr
    
    sr2 = SurveyResponse.new :survey_version_id => version.id, :client_id => '234', :status_id => 1, :worker_name => nil
    sr2.raw_responses.build :client_id => '234', :answer => "foo bar", :question_content => question.question_content, :status_id => 1, :survey_response => sr2
    
    sr.save! && sr2.save!
    
    sr.process_me(1)
    sr2.process_me(1)

    version.survey_responses.should have(2).responses
    
    sr.display_field_values.should have(1).dfv
    sr2.display_field_values.should have(1).dfv
    sr.display_field_values.first.update_attribute(:value, "This is a test")
    sr2.display_field_values.first.update_attribute(:value, "foo bar")
    
    version.survey_responses.search('test').should have(1).response
    version.survey_responses.search('').should have(2).responses
    version.survey_responses.search('should not match any').should have(0).responses
    version.survey_responses.search.should have(2).responses
  end
	
end