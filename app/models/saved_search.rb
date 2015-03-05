class SavedSearch < ActiveRecord::Base
  belongs_to :survey_version

  validates :name, presence: true
  validates :search_params, presence: true
end

# == Schema Information
#
# Table name: saved_searches
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  survey_version_id :integer
#  search_params     :text
#  created_at        :datetime
#  updated_at        :datetime
#

