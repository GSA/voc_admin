# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# This class is not yet implemented.
class Category < ActiveRecord::Base
  has_many :response_categories

  validates :name, :presence => true, :uniqueness=>true
end

# == Schema Information
# Schema version: 20110419132758
#
# Table name: categories
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
