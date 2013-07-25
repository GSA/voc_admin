class DashboardElement < ActiveRecord::Base
  belongs_to :dashboard
  has_one :survey_element

  ranks :sort_order, :column => :dashboard_id
end
