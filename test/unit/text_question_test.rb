require 'test_helper'

class TextQuestionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: text_questions
#
#  id          :integer(4)      not null, primary key
#  answer_type :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  clone_of_id :integer(4)
#

