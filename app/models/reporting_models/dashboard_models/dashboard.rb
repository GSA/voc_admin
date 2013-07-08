class Dashboard < ActiveRecord::Base
  belongs_to :survey_version
  has_many :dashboard_elements
end
