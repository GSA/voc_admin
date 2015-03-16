# == Schema Information
#
# Table name: execution_triggers
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe ExecutionTrigger do
	before(:each) do
		@valid_execution_trigger = ExecutionTrigger.new(:name => "test")
	end
	
	it "should be valid" do
		@valid_execution_trigger.should be_valid
	end
	
	it "is not valid without a presence (name)" do
		@valid_execution_trigger.name = nil
		@valid_execution_trigger.should_not be_valid
	end
	
	it "is not valid if not unique" do
		@valid_execution_trigger.dup.save
		@valid_execution_trigger.should_not be_valid
	end
end
