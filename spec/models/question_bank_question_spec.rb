# == Schema Information
#
# Table name: question_bank_questions
#
#  id               :integer          not null, primary key
#  question_bank_id :integer
#  bankable_id      :integer
#  bankable_type    :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

require 'spec_helper'

describe QuestionBankQuestion do
  pending "add some examples to (or delete) #{__FILE__}"
end
