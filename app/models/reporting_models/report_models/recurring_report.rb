class RecurringReport < ActiveRecord::Base
  belongs_to :report
  belongs_to :user_created_by, :class_name => "User"
  belongs_to :user_last_modified_by, :class_name => "User"

  validates_presence_of :report_id, :user_created_by_id, :frequency, :emails
  validates_presence_of :day_of_week, :if => Proc.new {|r| r.freqency == 'weekly'}
  validates_presence_of :day_of_month, :if => Proc.new {|r| ['monthly', 'quarterly'].include?(r.frequency)}
  validates_presence_of :month, :if => Proc.new {|r| r.frequency == 'quarterly'}

  def from_string
    str = user_created_by_string
    str += "and #{user_last_modified_by.email}" if user_last_modified
    str
  end

  def mail_report(force = false, skip_async = false)
    if user_created_by && user_created_by.email != user_created_by_string
      update_attribute(:user_created_by_string, user_created_by.email)
    end
    return false unless force || ready_to_mail? 
    async_method = pdf? ? :report_pdf : :report_csv
    if skip_async
      ReportsMailer.send(async_method, report_id, emails, from_string, frequency).deliver
    else
      ReportsMailer.async(async_method, report_id, emails, from_string, frequency)
    end
    update_attribute :last_sent_at, today
  end

  private
  def ready_to_mail?
    return false if last_sent_at.try(:to_date) == today.to_date
    case frequency
    when "daily" then true
    when "weekly" then weekly_ready_to_mail?
    when "monthly" then monthly_ready_to_mail?
    when "quarterly" then quarterly_ready_to_mail?
    else
      false
    end
  end

  def weekly_ready_to_mail?
    day_of_week == today.wday
  end

  def monthly_ready_to_mail?
    today.mday == day_of_month || 
        (today.mday == last_day_of_month && today.mday < day_of_month)
  end

  def quarterly_ready_to_mail?
    months = [month, month + 3, month + 6, month + 9].map {|m| m % 12}
    return false unless months.include?(today.month)
    monthly_ready_to_mail?
  end

  def today
    @today ||= Time.now
  end

  def last_day_of_month
    today.end_of_month.day
  end
end

# == Schema Information
#
# Table name: recurring_reports
#
#  id                       :integer(4)      not null, primary key
#  report_id                :integer(4)
#  user_created_by_id       :integer(4)
#  user_created_by_string   :string(255) - in case the user gets destroyed
#  user_last_modified_by_id :integer(4)
#  frequency                :string(255) - daily, weekly, monthly, quarterly
#  day_of_week              :integer(4)
#  day_of_month             :integer(4)
#  month                    :integer(4)
#  emails                   :string(1000)
#  pdf                      :boolean(1)
#  last_sent_at             :datetime
#  created_at               :datetime
#  updated_at               :datetime
