# The ChoiceAnswer class represents an answer to a ChoiceQuestion.
class ChoiceAnswer < ActiveRecord::Base
  belongs_to :choice_question
  belongs_to :page, :foreign_key => :next_page_id

  validates :answer, :presence => true, :length => {:in => 1..255}
  
  # ChoiceQuestion is represented as Radio buttons
  RADIO = "radio"
  # ChoiceQuestion is represented as Checkboxes
  CHECKBOX = "checkbox"
  # ChoiceQuestion is represented as a Dropdown / HTML <select>
  DROPDOWN = "dropdown"
  # ChoiceQuestion is represented as a Multiselect / HTML <select multiple="multiple">
  MULTISELECT = "multiselect"

  before_save :chomp_answer

  private
  # Before save, removes any trailing record separators or carriage returns.
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

