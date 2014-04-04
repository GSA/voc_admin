class RawSubmission < ActiveRecord::Base
  serialize :post, Hash
  attr_accessible :uuid_key, :survey_id, :survey_version_id, :post, :submitted
  validates_presence_of :uuid_key, :survey_id, :survey_version_id
end