# Used by Dashboard and Report models for start and end dates
module StartAndEndDates
  extend ActiveSupport::Concern

  REGEX_DATE = /(\d{2})[\/-](\d{2})[\/-](\d{2,4})/
  REGEX_DATE_REPLACE = '\3-\1-\2'

  included do
    validate :check_dates
  end

  def start_date_str
    read_attribute(:start_date).try(:to_s, :text_field)
  end

  def start_date=(start_date_str)
    if start_date_str.empty?
      write_attribute(:start_date, nil)
    else
      write_attribute(:start_date, Date.parse(start_date_str.gsub(REGEX_DATE, REGEX_DATE_REPLACE)))
    end
  rescue ArgumentError
    @start_date_invalid = true
  end

  def end_date_str
    read_attribute(:end_date).try(:to_s, :text_field)
  end

  def end_date=(end_date_str)
    if end_date_str.empty?
      write_attribute(:end_date, nil)
    else
      write_attribute(:end_date, Date.parse(end_date_str.gsub(REGEX_DATE, REGEX_DATE_REPLACE)))
    end
  rescue ArgumentError
    @end_date_invalid = true
  end

  protected

  def check_dates
    errors.add(:start_date, "is invalid") if @start_date_invalid
    errors.add(:end_date, "is invalid") if @end_date_invalid
  end
end
