# == Schema Information
# Schema version: 20110413183938
#
# Table name: raw_responses
#
#  id                :integer(4)      not null, primary key
#  survey_version_id :integer(4)
#  client_id         :string(255)
#  answer            :text
#  question_id       :integer(4)
#  status_id         :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#

class RawResponse < ActiveRecord::Base
  belongs_to :survey_version
  belongs_to :question_content, :foreign_key => :question_id
  
  validates :client_id, :presence => true, :uniqueness => {:scope => :question_id}
  validates :question_id, :presence => true, :numericality => true
  validates :answer, :presence => true
  validates :survey_version_id, :presence => true, :numericality => true
end
