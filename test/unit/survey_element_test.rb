require 'test_helper'

class SurveyElementTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: survey_elements
#
#  id                :integer(4)      not null, primary key
#  page_id           :integer(4)
#  element_order     :integer(4)
#  assetable_id      :integer(4)
#  assetable_type    :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  survey_version_id :integer(4)
#

