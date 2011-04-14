# == Schema Information
# Schema version: 20110411142125
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
#

class ChoiceAnswer < ActiveRecord::Base
  belongs_to :choice_question
  belongs_to :page, :foreign_key => :next_page_id

end
