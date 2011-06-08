require 'spec_helper'

describe Rule do
	before(:each) do
		@valid_rule = Rule.new(:name => "test", 
			:survey_version => mock_model(SurveyVersion), 
			:rule_order => 1)
			@valid_rule.stub(:execution_trigger_ids).and_return([1])
	end
	
	it "should be valid" do
		@valid_rule.should be_valid
	end
	
	it "is not valid without a presence (name)" do
		@valid_rule.name = nil
		@valid_rule.should_not be_valid
	end
	
	it "is not valid without a rule order" do
		@valid_rule.name = nil
		@valid_rule.should_not be_valid
	end
	
	it "is not valid with the same rule order in the scope of a survey version" do
		rule2 = @valid_rule.dup
		rule2.survey_version = @valid_rule.survey_version
		rule2.execution_triggers = [mock_model(ExecutionTrigger)]
		rule2.save!
		@valid_rule.should_not be_valid
	end
	
	it "is valid with the same rule order in different suvery versions" do
		rule2 = @valid_rule.dup
		rule2.survey_version = mock_model(SurveyVersion)
		rule2.execution_triggers = [mock_model(ExecutionTrigger)]
		rule2.save!
		@valid_rule.should be_valid
	end
	
	it "is not valid unless rule order is a number" do
		@valid_rule.rule_order = ""
		@valid_rule.should_not be_valid
	end
	
	it "is not valid without a survey version" do
		@valid_rule.survey_version = nil
		@valid_rule.should_not be_valid
	end
	
	it "is not valid without an execution trigger" do
		@valid_rule.stub(:execution_trigger_ids).and_return([])
		@valid_rule.should_not be_valid
	end
	
	it "should clone it self" do
   pending "need to figure out how to write this test" 
   @survey = Survey.create! :name => "Test Survey", :description => "Survey for testing"
   @version = @survey.survey_versions.first
   page1 = @version.pages.create! :page_number => @version.next_page_number
   QuestionContentObserver.instance.stub!(:after_create)
   
   text_question = TextQuestion.create!(
    :question_content_attributes => {:statement => "TQ 1"},
    :answer_type => "field",
    :survey_element_attributes => {:survey_version => @version, :page => page1}
   )
   
   @version.text_questions.should have(1).question
   exec_trigger = ExecutionTrigger.create! :name => "add"
   
      df = DisplayFieldText.create! :name => text_question.statement, :required => false, :searchable => false, :default_value => "", :display_order => (@version.display_fields.count + 1), 
        :survey_version_id => @version.id
      
      rule = @version.rules.create! :name => text_question.question_content.statement, :rule_order => (@version.rules.count + 1),
        :execution_trigger_ids => [exec_trigger.id],
        :criteria_attributes => [
          {:source_id => text_question.question_content.id, :source_type => "QuestionContent", :conditional_id => 10, :value => ""}
        ],
        :actions_attributes => [
          {:display_field_id => df.id, :value_type => "Response", :value => text_question.question_content.id.to_s}
        ]
   
   
   @version.reload
   @version.rules.should have(1).rule
   
   version_2 = @version.clone_me   
   version_2.rules.should have(1).rule
#    survey_version = mock_model(SurveyVersion)
#    DisplayField.stub!(:find_by_survey_version_id_and_clone_of_id).and_return(mock_model(DisplayField))
#	  @valid_rule.stub!(:criteria).and_return([mock_model(Criterion, :attributes=>{})])
#    @valid_rule.stub!(:actions).and_return([mock_model(Action, :attributes=>{:value=>"some value"}, :display_field_id=>1)])
#	  @valid_rule.stub!(:execution_triggers).and_return([mock_model(ExecutionTrigger)])
#	  @valid_rule.save!
#	  clone_rule = @valid_rule.clone_me(survey_version)
#	  clone_rule.clone_of_id.should == @valid_rule.id
#    clone_rule.criteria.size.should == @valid_rule.criteria.size
#	  clone_rule.actions.size.should == @valid_rule.actions.size
	end
end