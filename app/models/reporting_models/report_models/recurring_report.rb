class RecurringReport < ActiveRecord::Base
  belongs_to :report
  belongs_to :user_created_by, :class_name => "User"
  belongs_to :user_last_modified_by, :class_name => "User"

  validates_presence_of :report_id, :user_created_by_id, :frequency, :emails
  validates_presence_of :day_of_week, :if => Proc.new {|r| r.frequency == 'weekly'}
  validates_presence_of :day_of_month, :if => Proc.new {|r| ['monthly', 'quarterly'].include?(r.frequency)}
  validates_presence_of :month, :if => Proc.new {|r| r.frequency == 'quarterly'}

  FREQUENCIES = %w(daily weekly monthly quarterly)

  def from_string
    str = user_created_by_string
    str += "and #{user_last_modified_by.email}" if user_last_modified_by && user_last_modified_by_id != user_created_by_id
    str
  end

  def emailed_on_str
    case frequency
    when "daily" then "Daily"
    when "weekly" then Date::DAYNAMES[day_of_week]
    when "monthly" then day_of_month.ordinalize
    when "quarterly" then "#{months_str} #{day_of_month.ordinalize}"
    end
  end

  def doc_type
    pdf? ? 'PDF' : 'CSV'
  end

  def mail_report(force = false, skip_async = false)
    if user_created_by && user_created_by.email != user_created_by_string
      update_attribute(:user_created_by_string, user_created_by.email)
    end
    time = Time.now
    return false unless force || ready_to_mail?(time)
    async_method = pdf? ? :report_pdf : :report_csv
    if skip_async
      ReportsMailer.send(async_method, report_id, emails, from_string, frequency).deliver
    else
      ReportsMailer.async(async_method, report_id, emails, from_string, frequency)
    end
    update_attribute :last_sent_at, time
  end

  def ready_to_mail?(time = nil)
    time ||= Time.now
    return false if last_sent_at.try(:to_date) == time.to_date
    case frequency
    when "daily" then true
    when "weekly" then weekly_ready_to_mail?(time)
    when "monthly" then monthly_ready_to_mail?(time)
    when "quarterly" then quarterly_ready_to_mail?(time)
    else
      false
    end
  end

  private
  def weekly_ready_to_mail?(time)
    day_of_week == time.wday
  end

  def monthly_ready_to_mail?(time)
    time.mday == day_of_month ||
        (time.mday == time.end_of_month.day && time.mday < day_of_month)
  end

  def quarterly_ready_to_mail?(time)
    return false unless months.include?(time.month)
    monthly_ready_to_mail?(time)
  end

  def months
    [month, month + 3, month + 6, month + 9].map {|m| m % 12}
  end

  def months_str
    months.sort.map {|m| Date::ABBR_MONTHNAMES[m]}.join(', ')
  end
end

# == Schema Information
#
# Table name: recurring_reports
#
#  id                       :integer          not null, primary key
#  report_id                :integer
#  user_created_by_id       :integer
#  user_created_by_string   :string(255)
#  user_last_modified_by_id :integer
#  frequency                :string(255)
#  day_of_week              :integer
#  day_of_month             :integer
#  month                    :integer
#  emails                   :string(1000)
#  pdf                      :boolean
#  last_sent_at             :datetime
#  created_at               :datetime
#  updated_at               :datetime
#

