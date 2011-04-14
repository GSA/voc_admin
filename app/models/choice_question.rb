# == Schema Information
# Schema version: 20110411142125
#
# Table name: choice_questions
#
#  id          :integer(4)      not null, primary key
#  multiselect :boolean(1)
#  answer_type :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class ChoiceQuestion < ActiveRecord::Base
  has_one :survey_element, :as => :assetable
  has_one :question_content, :as => :questionable
  has_many :choice_answers
  
  validates :answer_type, :presence => true
  validates :question_content, :presence => true
  
  attr_accessible :answer_type, :question_content_attributes, :survey_element_attributes, :choice_answers_attributes
  accepts_nested_attributes_for :question_content
  accepts_nested_attributes_for :survey_element
  accepts_nested_attributes_for :choice_answers, :allow_destroy => true, :reject_if => proc { |obj| obj['answer'].blank? }
  
  
  

end
