# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# This class is not yet implemented.
class Category < ActiveRecord::Base
  has_many :response_categories

  validates :name, :presence => true, :uniqueness=>true
end

# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

