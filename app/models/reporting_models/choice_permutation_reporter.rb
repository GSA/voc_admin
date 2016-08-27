class ChoicePermutationReporter
  include Mongoid::Document

  field :ca_ids, type: String
  field :values, type: String
  field :count, type: Integer, default: 0

  embedded_in :choice_question_reporter
  embeds_many :choice_permutation_days
  index "choice_permutation_days.date" => 1

  def add_day(date)
    day = choice_permutation_days.find_or_create_by(date: date)
    day.inc(count: 1)    
    inc(count: 1)
  end

  def days_for_date_range(start_date, end_date)
    days = choice_permutation_days
    days = days.where(:date.gte => start_date.to_date) unless start_date.nil?
    days = days.where(:date.lte => end_date.to_date) unless end_date.nil?
    days
  end

  def count_for_date_range(start_date, end_date, force = false)
    return count if !force && start_date.nil? && end_date.nil?
    val = days_for_date_range(start_date, end_date).sum(:count)
    val.nil? ? 0 : val
  end

  Permutation = Struct.new(:values, :count)

  def permutation_for_date_range(start_date, end_date)
    days_count = count_for_date_range(start_date, end_date)
    Permutation.new(values.split(DisplayFieldValue::VALUE_DELIMITER), days_count)
  end
end
