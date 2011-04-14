# == Schema Information
# Schema version: 20110407172327
#
# Table name: text_questions
#
#  id          :integer(4)      not null, primary key
#  answer_type :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class TextQuestion < ActiveRecord::Base
  has_one :survey_element, :as => :assetable, :dependent => :destroy
  has_one :question_content, :as => :questionable, :dependent => :destroy
  
  validates :answer_type, :presence => true
  validates :question_content, :presence => true
  
  attr_accessible :answer_type, :question_content_attributes, :survey_element_attributes
  accepts_nested_attributes_for :question_content
  accepts_nested_attributes_for :survey_element
end
