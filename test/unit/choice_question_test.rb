require 'test_helper'

class ChoiceQuestionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: choice_questions
#
#  id                 :integer(4)      not null, primary key
#  multiselect        :boolean(1)
#  answer_type        :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  matrix_question_id :integer(4)
#  clone_of_id        :integer(4)
#

