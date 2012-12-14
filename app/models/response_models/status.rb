# == Schema Information
# Schema version: 20110419132758
#
# Table name: statuses
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)     not null
#  created_at :datetime
#  updated_at :datetime
#

class Status < ActiveRecord::Base
  NEW = 1
  PROCESSING = 2
  ERROR = 3
  DONE = 4

  has_many :raw_responses

  validates :name, :presence => true, :uniqueness => true
end
