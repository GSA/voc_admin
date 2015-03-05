class SavedSearch < ActiveRecord::Base
  belongs_to :survey_version

  validates :name, presence: true
  validates :search_params, presence: true
end
