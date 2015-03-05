# == Schema Information
#
# Table name: raw_submissions
#
#  id                :integer          not null, primary key
#  uuid_key          :string(255)
#  survey_id         :integer
#  survey_version_id :integer
#  post              :text(16777215)
#  submitted         :boolean          default(FALSE)
#  created_at        :datetime
#  updated_at        :datetime
#

class RawSubmission < ActiveRecord::Base
  serialize :post, Hash
  attr_accessible :uuid_key, :survey_id, :survey_version_id, :post, :submitted
  validates_presence_of :uuid_key, :survey_id, :survey_version_id, :post
  validates_length_of :post, :in => 1..65535
end
