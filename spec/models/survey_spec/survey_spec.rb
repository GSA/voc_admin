# == Schema Information
#
# Table name: surveys
#
#  id                            :integer          not null, primary key
#  name                          :string(255)
#  description                   :text
#  survey_type_id                :integer
#  created_at                    :datetime
#  updated_at                    :datetime
#  archived                      :boolean          default(FALSE)
#  site_id                       :integer
#  submit_button_text            :string(255)
#  previous_page_text            :string(255)
#  next_page_text                :string(255)
#  js_required_fields_error      :string(255)
#  invitation_percent            :integer          default(100), not null
#  invitation_interval           :integer          default(30), not null
#  invitation_text               :text
#  invitation_accept_button_text :string(255)
#  invitation_reject_button_text :string(255)
#  alarm                         :boolean
#  alarm_notification_email      :string(255)
#  holding_page                  :text
#  show_numbers                  :boolean          default(TRUE)
#  locale                        :string(255)
#  start_screen_button_text      :string(255)
#  start_page_title              :string(255)
#  invitation_preview_stylesheet :string(255)
#  survey_preview_stylesheet     :string(255)
#

require 'spec_helper'

describe Survey do
  let(:survey) { build :survey }

  it "should create a new survey given valid attributes" do
    survey.should be_valid
  end

  it "should require a name" do
    survey.name = nil
    survey.should_not be_valid
    survey.errors[:name].should include("can't be blank")
  end

  it "should require a description" do
    survey.description = nil
    survey.should_not be_valid
    survey.errors[:description].should include("can't be blank")
  end

  it "should reject duplicate names" do
    survey.dup.save!
    survey.should_not be_valid
    survey.errors[:name].should include("has already been taken")
  end

  it "should reject names longer than 255 characters" do
    survey.name = "a" * 256
    survey.should_not be_valid
    survey.errors[:name].should include("is too long (maximum is 255 characters)")
  end

  it "should reject descriptions longer than 65535 characters" do
    survey.description = "a" * 65536
    survey.should_not be_valid
    survey.errors[:description].should include("is too long (maximum is 65535 characters)")
  end

  it "should create a major version on creation" do
    survey.save!
    survey.survey_versions.should have(1).version
  end

  it "should create version 1.0 on survey create" do
    survey.save!
    survey.survey_versions.first.version_number.should == "1.0"
  end

  it "should create a new minor version" do
    survey.save!
    survey.create_new_minor_version
    survey.survey_versions.should have(2).versions
    survey.survey_versions.last.version_number.should == "1.1"
  end

  it "should create a copy of the specified survey_version" do
    survey.save!
    survey.create_new_minor_version survey.survey_versions.first.id
    survey.survey_versions.should have(2).records
    pending "need to implement survey_version compare method"
  end

  it "should return the survey_version with the highest major and minor numbers" do
    survey.save!
    new_sv = survey.create_new_major_version
    survey.newest_version.should == new_sv
  end

  it "should create a new major version" do
    survey.save!
    new_major_version = survey.create_new_major_version
    survey.survey_versions.should have(2).versions
    new_major_version.major.should == 2
  end

  it 'should create an initial page for new major versions' do
      survey.save!
      survey_version = survey.create_new_major_version
      survey_version.pages.should_not be_empty
      survey_version.pages.first.page_number.should == 1
  end

  it "should not be valid without a site" do
   survey.site = nil
   survey.should_not be_valid
   survey.errors[:site].should include("can't be blank")
  end

  it "should return the currently published version" do
    survey.save!
    survey.survey_versions.first.publish_me
    survey.published_version.should == survey.survey_versions.first
  end

  it 'should return the latest published version' do
    survey.save!
    survey.survey_versions.first.publish_me

    survey.published_version.should == survey.survey_versions.first

    sv = survey.create_new_major_version
    sv.update_attribute(:published, true)

    # we now have 1.0 and 2.0 both marked as published.
    # survey.published_version should return 2.0 as the published version
    survey.published_version.should == sv

    sv = survey.create_new_minor_version(survey.survey_versions.last)
    sv.update_attribute(:published, true)

    survey.published_version.should == sv
  end
end
