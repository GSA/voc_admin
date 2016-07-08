class QuestionBankQuestion < ActiveRecord::Base
  belongs_to :question_bank
  belongs_to :bankable, polymorphic: true
end

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

