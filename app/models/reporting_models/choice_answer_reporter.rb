class ChoiceAnswerReporter
  include Mongoid::Document

  field :ca_id, type: Integer
  field :text, type: String
  field :count, type: Integer, default: 0

  embedded_in :choice_question_reporter
  embeds_many :choice_answer_days
  index "choice_answer_days.date" => 1

  def add_day(date)
    day = choice_answer_days.find_or_create_by(date: date)
    day.inc(count: 1)
    inc(count: 1)
  end

  def days_for_date_range(start_date, end_date)
    days = choice_answer_days
    days = days.where(:date.gte => start_date.to_date) unless start_date.nil?
    days = days.where(:date.lte => end_date.to_date) unless end_date.nil?
    days
  end

  def count_for_date_range(start_date, end_date, force = false)
    return count if !force && start_date.nil? && end_date.nil?
    val = days_for_date_range(start_date, end_date).sum(:count)
    val.nil? ? 0 : val
  end

  def answer_percentage_for_date_range(start_date, end_date)
    count_for_dates = count_for_date_range(start_date, end_date)
    answered_for_dates = choice_question_reporter.answered_for_date_range(start_date, end_date)
    count_for_dates * 100.0 / answered_for_dates
  end
end
