require 'test_helper'

class ExecutionTriggerRuleTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: execution_trigger_rules
#
#  id                   :integer(4)      not null, primary key
#  rule_id              :integer(4)      not null
#  execution_trigger_id :integer(4)      not null
#  created_at           :datetime
#  updated_at           :datetime
#

