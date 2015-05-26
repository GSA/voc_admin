class RawSubmission < ActiveRecord::Base
  has_one :survey_response 

  attr_accessible :uuid_key, :survey_id, :survey_version_id, :post, :submitted
  validates_presence_of :uuid_key, :survey_id, :survey_version_id, :post
  validates_length_of :post, :in => 1..65535

  def post=(val)
    write_attribute :post, val.to_json
  end

  def post
    data = read_attribute(:post)
    data && JSON.parse(data)
  end
end
