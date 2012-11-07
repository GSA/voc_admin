require 'spec_helper'

describe Role do
  let(:role) {build :role}

  it "should be valid" do
  	role.should be_valid
  end

  it "should not be valid without a name" do
  	role.name = nil
  	role.should_not be_valid
  	role.errors[:name].should include("can't be blank")
  end

  it "should not be valid without a unique name" do
  	role.dup.save!
  	role.should_not be_valid
  	role.errors[:name].should include("has already been taken")
  end
end

# == Schema Information
#
# Table name: roles
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

