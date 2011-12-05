require 'test_helper'

class RawResponseTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: raw_responses
#
#  id                  :integer(4)      not null, primary key
#  client_id           :string(255)
#  answer              :text
#  question_content_id :integer(4)
#  status_id           :integer(4)      default(1), not null
#  created_at          :datetime
#  updated_at          :datetime
#  worker_name         :string(255)
#  survey_response_id  :integer(4)      not null
#

