# == Schema Information
# Schema version: 20110407172639
#
# Table name: question_contents
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)
#  statement         :string(255)
#  number            :integer(4)
#  questionable_type :string(255)
#  questionable_id   :integer(4)
#  display_id        :integer(4)
#  flow_control      :boolean(1)
#  required          :boolean(1)
#  created_at        :datetime
#  updated_at        :datetime
#

class QuestionContent < ActiveRecord::Base
  belongs_to :questionable, :polymorphic => true
  
  #validates :name, :presence => true
  validates :statement, :presence => true
#  validates :number, :presence => true, :numericality => true
  
  attr_accessible :name, :statement, :number, :flow_control, :required
  
end
