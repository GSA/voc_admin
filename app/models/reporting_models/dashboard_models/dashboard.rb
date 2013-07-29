class Dashboard < ActiveRecord::Base
  belongs_to :survey_version
  has_many :dashboard_elements
  accepts_nested_attributes_for :dashboard_elements

  validates :name, :presence => true
end
