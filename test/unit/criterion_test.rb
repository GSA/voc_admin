require 'test_helper'

class CriteriaTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: criteria
#
#  id             :integer(4)      not null, primary key
#  rule_id        :integer(4)      not null
#  source_id      :integer(4)      not null
#  conditional_id :integer(4)      not null
#  value          :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  source_type    :string(255)     not null
#  clone_of_id    :integer(4)
#

