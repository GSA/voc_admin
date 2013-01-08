# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Join relationship between ExecutionTriggers and Rules.
class ExecutionTriggerRule < ActiveRecord::Base
  belongs_to :rule
  belongs_to :execution_trigger
end

# == Schema Information
# Schema version: 20110420193126
#
# Table name: execution_trigger_rules
#
#  id                   :integer(4)      not null, primary key
#  rule_id              :integer(4)      not null
#  execution_trigger_id :integer(4)      not null
#  created_at           :datetime
#  updated_at           :datetime
