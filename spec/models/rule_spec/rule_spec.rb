require 'spec_helper'

describe Rule do
	before(:each) do
		@valid_rule = Rule.new(:name => "test", 
			:survey_version => mock_model(SurveyVersion), 
			:rule_order => 1
			)
			@valid_rule.stub(:execution_trigger_ids).and_return([1])
			@valid_rule.stub(:execution_triggers).and_return([mock_model(ExecutionTrigger, :id => 1)])
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
	  target_sv = mock_model(SurveyVersion, :rules => [])
	  target_sv.stub_chain(:rules, :find_by_name).and_return(nil)
	  @valid_rule.survey_version.stub(:rules).and_return(@valid_rule)
	  @valid_rule.should be_valid
	  cloned_rule = @valid_rule.clone_me(target_sv)
	  
    cloned_rule.should_not be_nil
    cloned_rule.name.should == @valid_rule.name
    cloned_rule.execution_triggers.should have(1).execution_trigger
    cloned_rule.criteria.should have(@valid_rule.criteria.count).criteria
    cloned_rule.actions.should have(@valid_rule.actions.count).actions
	end
	
  it "clone_of_id is set when a rule is cloned" do
	  target_sv = mock_model(SurveyVersion, :rules => [])
	  target_sv.stub_chain(:rules, :find_by_name).and_return(nil)
	  @valid_rule.survey_version.stub(:rules).and_return(@valid_rule)
	  @valid_rule.should be_valid
	  cloned_rule = @valid_rule.clone_me(target_sv)    
	  
	  cloned_rule.clone_of_id.should == @valid_rule.id
  end
end