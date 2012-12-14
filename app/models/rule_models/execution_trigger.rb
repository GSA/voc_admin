# == Schema Information
# Schema version: 20110420193126
#
# Table name: execution_triggers
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)     not null
#  created_at :datetime
#  updated_at :datetime
#

class ExecutionTrigger < ActiveRecord::Base

  ADD = 1
  UPDATE = 2
  DELETE = 3
  NIGHTLY = 4

  validates :name, :presence=>true, :uniqueness=>true
end
