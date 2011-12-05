require 'test_helper'

class ResponseCategoryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: response_categories
#
#  id                  :integer(4)      not null, primary key
#  category_id         :integer(4)      not null
#  process_response_id :integer(4)      not null
#  created_at          :datetime
#  updated_at          :datetime
#  survey_version_id   :integer(4)      not null
#

