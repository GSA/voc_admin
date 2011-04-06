class Survey < ActiveRecord::Base
  has_many :survey_versions
  
  attr_accessible :name, :description
  
  validates :name, :presence => true, :length => {:in => 1..255}
  validates :description, :presence => true, :length => {:in => 1..65535}
  validates :type, :presence => true
end
