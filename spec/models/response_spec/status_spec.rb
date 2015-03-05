# == Schema Information
#
# Table name: statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Conditional do
	before(:each) do
		@valid_status = Conditional.new(:name => "test")
	end
	
	it "should be valid" do
		@valid_status.should be_valid
	end
	
	it "is not valid without a presence (name)" do
		@valid_status.name = nil
		@valid_status.should_not be_valid
	end
	
	it "is not valid if not unique" do
		@valid_status.dup.save
		@valid_status.should_not be_valid
	end
end
