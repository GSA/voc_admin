class Dashboard < ActiveRecord::Base
  include StartAndEndDates

  belongs_to :survey_version
  has_many :dashboard_elements, :dependent => :destroy
  accepts_nested_attributes_for :dashboard_elements, :allow_destroy => true

  validates :name, :presence => true
end
