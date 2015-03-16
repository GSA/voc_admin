# == Schema Information
#
# Table name: users
#
#  id                :integer          not null, primary key
#  f_name            :string(255)      not null
#  l_name            :string(255)      not null
#  locked            :boolean
#  email             :string(255)      not null
#  crypted_password  :string(255)
#  password_salt     :string(255)
#  persistence_token :string(255)      not null
#  created_at        :datetime
#  updated_at        :datetime
#  role_id           :integer
#  hhs_id            :string(50)
#  last_request_at   :datetime
#

require 'spec_helper'

describe User do
  before(:each) do
    @valid_user = User.new(:email => "email@example.com", :password => "password", :password_confirmation => "password", :f_name => "Example", :l_name => "User")
  end

  it "should be valid with valid attributes" do
    @valid_user.should be_valid
  end

  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:f_name) }
  it { should validate_presence_of(:l_name) }

  it "should write the email to the database in lowercase" do
    email = "CAPITAL_EMAIL@TEST.COM"
    User.new(:email => email).email.should == email.downcase
  end

  it "should request default Survey scope if admin" do
    User.any_instance.stub(:admin?).and_return(true)
    Survey.stub(:scoped)
    Survey.should_receive(:scoped)

    @valid_user.surveys
  end

  it "should request User-and-Site-specific Surveys if not admin" do
    User.any_instance.stub(:admin?).and_return(false)
    Survey.stub(:includes).and_return(Survey)
    Survey.stub(:where).and_return(Survey)

    Survey.should_receive(:includes)
    Survey.should_receive(:where)

    @valid_user.surveys
  end

  it "should return true if user is admin" do
    @valid_user.role = Role::ADMIN

    @valid_user.admin?.should be_true
  end

  it "should return false if user is not admin" do
    @valid_user.role = nil

    @valid_user.admin?.should be_false
  end
end
