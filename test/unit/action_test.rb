require 'test_helper'

class ActionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: actions
#
#  id               :integer(4)      not null, primary key
#  rule_id          :integer(4)      not null
#  display_field_id :integer(4)      not null
#  value            :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  value_type       :string(255)
#  clone_of_id      :integer(4)
#

