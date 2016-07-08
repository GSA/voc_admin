# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Join relationship between ExecutionTriggers and Rules.
class ExecutionTriggerRule < ActiveRecord::Base
  belongs_to :rule
  belongs_to :execution_trigger
end

# == Schema Information
#
# Table name: execution_trigger_rules
#
#  id                   :integer          not null, primary key
#  rule_id              :integer          not null
#  execution_trigger_id :integer          not null
#  created_at           :datetime
#  updated_at           :datetime
#

