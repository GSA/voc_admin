class Report < ActiveRecord::Base
  belongs_to :survey_version
  has_many :report_elements

  validates :name, :presence => true
end
