class QuestionBankQuestion < ActiveRecord::Base
  belongs_to :question_bank
  belongs_to :bankable, polymorphic: true
end
