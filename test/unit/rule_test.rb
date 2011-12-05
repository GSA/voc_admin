require 'test_helper'

class RuleTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: rules
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)     not null
#  created_at        :datetime
#  updated_at        :datetime
#  survey_version_id :integer(4)      not null
#  rule_order        :integer(4)      not null
#  clone_of_id       :integer(4)
#

