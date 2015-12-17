class QuestionBank < ActiveRecord::Base
  has_many :question_bank_questions
  has_many :text_questions, through: :question_bank_questions,
    source: :bankable, source_type: 'TextQuestion'
  has_many :choice_questions, through: :question_bank_questions,
    source: :bankable, source_type: 'ChoiceQuestion'
  has_many :matrix_questions, through: :question_bank_questions,
    source: :bankable, source_type: 'MatrixQuestion'


  def self.instance
    find_or_create_by(id: 1)
  end

  def questions
    question_bank_questions.collect {|q| q.bankable }
  end
end

# == Schema Information
#
# Table name: question_banks
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

