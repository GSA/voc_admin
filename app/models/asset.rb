# == Schema Information
# Schema version: 20110415192145
#
# Table name: assets
#
#  id         :integer(4)      not null, primary key
#  snippet    :text
#  created_at :datetime
#  updated_at :datetime
#

class Asset < ActiveRecord::Base
  has_one :survey_element, :as => :assetable, :dependent => :destroy
  
  attr_accessible :survey_element_attributes, :snippet
  
  validates :snippet, :presence => true
  
  
end
