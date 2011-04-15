class Asset < ActiveRecord::Base
  has_one :survey_element, :as => :assetable, :dependent => :destroy
  
  attr_accessible :survey_element_attributes, :snippet
  
  validates :snippet, :presence => true
  
  
end
