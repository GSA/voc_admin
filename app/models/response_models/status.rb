# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Contains mapping values for the RawResponse processing status codes.
class Status < ActiveRecord::Base
  # A freshly created record.
  NEW = 1
  # Currently being processed.
  PROCESSING = 2
  # A processing error has occurred.
  ERROR = 3
  # Processing has completed successfully.
  DONE = 4

  has_many :raw_responses

  validates :name, :presence => true, :uniqueness => true
end

# == Schema Information
#
# Table name: statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

