class Report < ActiveRecord::Base
  belongs_to :survey_version
  has_many :widgets, as: :reportable
end
