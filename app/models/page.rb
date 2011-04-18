# == Schema Information
# Schema version: 20110407170345
#
# Table name: pages
#
#  id                :integer(4)      not null, primary key
#  number            :integer(4)
#  survey_version_id :integer(4)
#  style_id          :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#

class Page < ActiveRecord::Base
  belongs_to :survey_version
  has_many :survey_elements, :dependent => :destroy
  
  validates :number, :presence => true, :numericality => true, :uniqueness => {:scope => :survey_version_id}
  
end
