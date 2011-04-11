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
  has_one :survey_element, :as => :assetable
  
  validates :answer_type, :presence => true
end
