class Report < ActiveRecord::Base
  include StartAndEndDates

  belongs_to :survey_version
  has_many :report_elements, :dependent => :destroy
  accepts_nested_attributes_for :report_elements, :allow_destroy => true

  validates :name, :presence => true
end
