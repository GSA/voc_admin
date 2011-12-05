require 'test_helper'

class DisplayFieldValueTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: display_field_values
#
#  id                 :integer(4)      not null, primary key
#  display_field_id   :integer(4)      not null
#  survey_response_id :integer(4)      not null
#  value              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

