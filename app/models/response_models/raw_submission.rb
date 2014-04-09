class RawSubmission < ActiveRecord::Base
  serialize :post, Hash
  attr_accessible :uuid_key, :survey_id, :survey_version_id, :post, :submitted
  validates_presence_of :uuid_key, :survey_id, :survey_version_id, :post
  validates_length_of :post, :in => 1..65535
end