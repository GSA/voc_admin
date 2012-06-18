require 'spec_helper'

describe Site do
  def valid_attributes
    {
      name: "Test Site",
      url: "http://www.example.com",
      description: "This is a test site created by Rspec"
    }
  end

  let(:site) { build :site }

  it "should be valid" do
    site.should be_valid
  end

  it "should not be valid without a name" do
    site.name = nil
    site.should_not be_valid
    site.errors[:name].should include("can't be blank")
  end

  it "should not be valid without a URL" do
    site.url = nil
    site.should_not be_valid
    site.errors[:url].should include("can't be blank")
  end

  it "should not be valid without a description" do
    site.description = nil
    site.should_not be_valid
    site.errors[:description].should include("can't be blank")
  end

  it "should not be valid with a name longer than 255 characters" do
    site.name = "A" * 256
    site.should_not be_valid
    site.errors[:name].should include("is too long (maximum is 255 characters)")
  end

  it "should not be valid with a url longer than 255 characters" do
    site.url = "a" * 256
    site.should_not be_valid
    site.errors[:url].should include("is too long (maximum is 255 characters)")
  end

  it "should not be valid with a description longer than 4000 characters" do
    site.description = "A" * 4001
    site.should_not be_valid
    site.errors[:description].should include("is too long (maximum is 4000 characters)")
  end

  it "should not be valid without a unique name" do
    site.dup.save!
    site.should_not be_valid
    site.errors[:name].should include("has already been taken")
  end

  it "should not be valid without a unique url" do
    site.dup.save!
    site.should_not be_valid
    site.errors[:url].should include("has already been taken")
  end

  it "should not be valid without a properly formatted url" do
    site.url = "test"
    site.should_not be_valid
    site.errors[:url].should include("is not a valid url")
  end

end

# == Schema Information
#
# Table name: sites
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  url         :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

