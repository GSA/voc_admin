class DashboardElement < ActiveRecord::Base
  belongs_to :dashboard
  has_one :survey_element
end
