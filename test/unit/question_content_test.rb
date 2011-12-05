require 'test_helper'

class QuestionContentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: question_contents
#
#  id                :integer(4)      not null, primary key
#  statement         :string(255)
#  questionable_type :string(255)
#  questionable_id   :integer(4)
#  flow_control      :boolean(1)
#  required          :boolean(1)      default(FALSE)
#  created_at        :datetime
#  updated_at        :datetime
#

