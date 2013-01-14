class ChoiceAnswer < ActiveRecord::Base
  belongs_to :choice_question
  belongs_to :page, :foreign_key => :next_page_id

  validates :answer, :presence => true, :length => {:in => 1..255}
  #validates :answer_order, :presence => true, :numericality => true, :uniqueness => {:scope => :choice_question_id}

  RADIO = "radio"
  CHECKBOX = "checkbox"
  DROPDOWN = "dropdown"
  MULTISELECT = "multiselect"


  before_save :chomp_answer

  private
  def chomp_answer
    self.answer.chomp!
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
#  is_default         :boolean(1)      default(FALSE)
#

