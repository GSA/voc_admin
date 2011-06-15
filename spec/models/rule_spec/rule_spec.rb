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
	
	
	# This is in need of some major refactoring.  Should not need to clone a question in order to 
	# test cloning a rule.  Should be able to set up a mocked cloned question to use without hitting the
	# database
	it "should clone it self" do
	  survey = Survey.create! :name => "Rule clone test survey", :description => "RSpec test survey"
	  version = survey.survey_versions.first
	  page = version.pages.create! :page_number => 1
	  question = TextQuestion.new(
	   :answer_type => 'field',
	   :question_content_attributes => {:statement => "Test Text Question"}
	  )
	  
	  question.build_survey_element(
	   :element_order => 1,
	   :survey_version => version,
	   :page => page
	  )
	  
	  question.should be_valid
	  
	  question.save!
	  
	  version.questions.should have(1).question
	  version.rules.should have(1).rule
	  version.display_fields.should have(1).display_field
	  
	  target_sv = survey.create_new_major_version
	  page.clone_me(target_sv)
	  target_sv.pages.should have(1).page
	  
	  question.clone_me(target_sv)
	  target_sv.questions.should have(1).question
	  target_sv.rules.should have(1).rule
	  target_sv.display_fields.should have(1).display_field
	  
	  cloned_rule = target_sv.rules.first
	  cloned_rule.name.should == version.rules.first.name
	  cloned_rule.criteria.should have(1).criteria
	  cloned_rule.actions.should have(1).action
	end
end