require 'test_helper'

class MatrixQuestionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: matrix_questions
#
#  id                :integer(4)      not null, primary key
#  created_at        :datetime
#  updated_at        :datetime
#  survey_version_id :integer(4)
#  clone_of_id       :integer(4)
#

