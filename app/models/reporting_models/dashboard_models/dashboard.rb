class Dashboard < ActiveRecord::Base
  include StartAndEndDates

  belongs_to :survey_version
  has_many :dashboard_elements, :dependent => :destroy
  accepts_nested_attributes_for :dashboard_elements, :allow_destroy => true

  validates :name, :presence => true
end

# == Schema Information
#
# Table name: dashboards
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)
#  survey_version_id :integer(4)      not null
#  start_date        :date
#  end_date          :date
#  created_at        :datetime
#  updated_at        :datetime
