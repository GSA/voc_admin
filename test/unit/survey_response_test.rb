require 'test_helper'

class SurveyResponseTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: survey_responses
#
#  id                :integer(4)      not null, primary key
#  client_id         :string(255)
#  survey_version_id :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#  status_id         :integer(4)      default(1), not null
#  last_processed    :datetime
#  worker_name       :string(255)
#

