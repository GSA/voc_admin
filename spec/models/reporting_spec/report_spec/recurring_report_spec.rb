require 'spec_helper'
include SurveyHelpers

describe RecurringReport do
  before do
    publish_survey_version
    build_three_simple_responses
    @report = @v.reports.create(name: "Report")
    @user = create(:user)
  end

  let(:report) { generate_recurring_report('daily') }

  context "daily report" do
    it "should only mail once in a day" do
      ReportsMailer.should_receive(:async).once.and_return(true)
      report.ready_to_mail?.should be_true
      report.mail_report.should be_true
      report.ready_to_mail?.should be_false
      report.mail_report.should be_false
    end
  end

  context "weekly report" do
    let(:report) { generate_recurring_report('weekly') }

    it "should only mail on the given weekday" do
      (0..5).each do |i|
        time = Time.parse('2013/10/20') + i.day
        report.ready_to_mail?(time).should be_false
      end
      time = Time.parse('2013/10/20') + 6.day
      report.ready_to_mail?(time).should be_true
    end
  end

  context "monthly report" do
    let(:report) { generate_recurring_report('monthly') }

    it "should only mail on the given day, or last day of month if that day doesn't exist in the month" do
      time = Date.parse('2013/01/01')
      times_mailed = 0
      (0..364).each do |i|
        new_time = time + i.day
        if new_time.end_of_month == new_time
          report.ready_to_mail?(new_time).should be_true
          times_mailed += 1
        else
          report.ready_to_mail?(new_time).should be_false
        end
      end
      times_mailed.should == 12
    end
  end

  context "quarterly report" do
    let(:report) { generate_recurring_report('quarterly') }

    it "should only mail on the given day, or last day of month if that day doesn't exist in the month" do
      time = Date.parse('2013/01/01')
      times_mailed = 0
      months = [2, 5, 8, 11]
      (0..364).each do |i|
        new_time = time + i.day
        if months.include?(new_time.month) && new_time.end_of_month == new_time
          report.ready_to_mail?(new_time).should be_true
          times_mailed += 1
        else
          report.ready_to_mail?(new_time).should be_false
        end
      end
      times_mailed.should == 4
    end
  end

  def generate_recurring_report(frequency)
    attrs = {user_created_by: @user, emails: "example@example.com", pdf: false, frequency: frequency}
    case frequency
    when 'weekly'
      attrs[:day_of_week] = 6
    when 'monthly'
      attrs[:day_of_month] = 31
    when 'quarterly'
      attrs[:month] = 11
      attrs[:day_of_month] = 31
    end
    @report.recurring_reports.create(attrs)
  end
end
