require 'spec_helper'

describe QuestionContentObserver do
  context "when a question content is updated" do
    it "should update the display field name when a question is updated" do
      mock_field = mock_model(DisplayField)
      fields = [mock_field]
      mock_version = mock_model(SurveyVersion, :display_fields => fields)
      mock_content = mock_model(QuestionContent,
        :statement_changed? => true, 
        :statement_was => "Old DispalyField Name", 
        :survey_version => mock_version, 
        :statement => "New DisplayField Name",
        :questionable_type => "TextQuestion"
      )
      fields.stub(:find_by_name).and_return(mock_field)
      
      mock_field.should_receive(:update_attributes).with(:name => "New DisplayField Name").once
      
      qc_observer = QuestionContentObserver.instance
      qc_observer.after_update(mock_content)

    end  
  end
  
  context "when a new question content created" do
    it "should create a new display field"
  
    it "should create a new rule"
  end
end