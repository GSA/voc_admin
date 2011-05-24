require 'spec_helper'

describe Conditional do
	before(:each) do
		@valid_conditional = Conditional.new(:name => "test")
	end
	
	it "should be valid" do
		@valid_conditional.should be_valid
	end
	
	it "is not valid without a presence (name)" do
		@valid_conditional.name = nil
		@valid_conditional.should_not be_valid
	end
	
	it "is not valid if not unique" do
		@valid_conditional.dup.save
		@valid_conditional.should_not be_valid
	end
end