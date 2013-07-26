class DashboardElement < ActiveRecord::Base
  belongs_to :dashboard
  has_one :survey_element

  serialize :options

  include RankedModel
  ranks :sort_order, :column => :dashboard_id
end
