require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before(:each) do
    @valid_user = User.new(:email => "example@example.com", :password => "password", :password_confirmation => "password", :f_name => "Example", :l_name => "User")
  end
  
  it "should be valid with valid attributes" do
    @valid_user.should be_valid
  end
  
  it "is not valid without an email" do
    @valid_user.email = nil
    @valid_user.should_not be_valid
  end
  
  it "is not valid without a password" do
    @valid_user.password = nil
    @valid_user.password_confirmation = nil
    @valid_user.should_not be_valid
  end
  
  it "is not valid without a first name" do
    @valid_user.f_name = nil
    @valid_user.should_not be_valid
  end
  
  it "is not valid without a last name" do
    @valid_user.l_name = nil
    @valid_user.should_not be_valid
  end
end
