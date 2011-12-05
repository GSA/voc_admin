require 'test_helper'

class ChoiceAnswerTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: choice_answers
#
#  id                 :integer(4)      not null, primary key
#  answer             :string(255)
#  choice_question_id :integer(4)
#  answer_order       :integer(4)
#  next_page_id       :integer(4)
#  created_at         :datetime
#  updated_at         :datetime
#  clone_of_id        :integer(4)
#

