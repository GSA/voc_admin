class Role < ActiveRecord::Base
  attr_accessible :name

  has_many :users

  validates :name, presence: true, uniqueness: true

  ADMIN = Role.find_or_create_by_name("Admin")
end

# == Schema Information
#
# Table name: roles
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

