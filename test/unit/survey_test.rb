require 'test_helper'

class SurveyTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: surveys
#
#  id             :integer(4)      not null, primary key
#  name           :string(255)
#  description    :text
#  survey_type_id :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#  archived       :boolean(1)      default(FALSE)
#

