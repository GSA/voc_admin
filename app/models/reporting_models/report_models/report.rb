class Report < ActiveRecord::Base
  include StartAndEndDates

  belongs_to :survey_version
  has_many :report_elements, :dependent => :destroy
  has_many :recurring_reports, :dependent => :destroy
  accepts_nested_attributes_for :report_elements, :allow_destroy => true

  validates :name, :presence => true

  def text_question_reporters
    @text_question_reporters ||= SurveyVersionReporter.where(sv_id: survey_version_id).first.try(:text_question_reporters)
  end

  def choice_question_reporters
    @choice_question_reporters ||= SurveyVersionReporter.where(sv_id: survey_version_id).first.try(:choice_question_reporters)
  end

  def to_csv
    CSV.generate do |csv|
      csv_report_information(csv)
      csv_text_question_reporters(csv)
      csv_choice_question_reporters(csv)
    end
  end

  private
  def csv_report_information(csv)
    csv << ["Survey: #{survey_version.survey.name.titleize}"]
    csv << ["Version: #{survey_version.version_number}"]
    csv << ["Report Name: #{name}"]
    csv << ["Start Date: #{start_date_str}"]
    csv << ["End Date: #{end_date_str}"]
    csv << []
  end

  def csv_text_question_reporters(csv)
    if text_question_reporters.count > 0
      csv << ["Question", "Top Words"]
      text_question_reporters.each do |tqr|
        csv << [tqr.question_text, tqr.top_words_str(start_date, end_date)]
      end
      csv << []
    end
  end

  def csv_choice_question_reporters(csv)
    if choice_question_reporters.count > 0
      csv << ["Question", "Answers"]
      choice_question_reporters.each do |cqr|
        csv << [cqr.question_text, cqr.choice_answers_str(start_date, end_date)]
      end
      csv << []
    end
  end
end

# == Schema Information
#
# Table name: reports
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)
#  survey_version_id :integer(4)      not null
#  start_date        :date
#  end_date          :date
#  created_at        :datetime
#  updated_at        :datetime
