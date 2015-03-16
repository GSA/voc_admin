require 'spec_helper'

describe EmailAction do
  context "validations" do
    it { should validate_presence_of(:emails)}
    it { should validate_presence_of(:subject)}
    it { should validate_presence_of(:body)}
  end

  context "perform" do
    it "should call RulesMailer.email_action_notification as a delayed_job" do
      Resque.reset!
      RulesMailer.stub(:delay).and_return(RulesMailer)
      RulesMailer.stub(:email_action_notification)
      RulesMailer.should_receive(:email_action_notification).with(any_args()).and_return(double("mailer", :deliver => true))

      ea = build :email_action
      ea.perform(build :survey_response, :display_field_values => [mock_model(DisplayFieldValue, :[]= => true, :save => true, :value => 'test')])
      Resque.run!
    end
  end
end

# == Schema Information
#
# Table name: email_actions
#
#  id          :integer          not null, primary key
#  emails      :string(255)
#  subject     :string(255)
#  body        :text
#  rule_id     :integer
#  clone_of_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

