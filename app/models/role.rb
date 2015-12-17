# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# The User's Role within the admin application.
class Role < ActiveRecord::Base
  attr_accessible :name

  has_many :users

  validates :name, presence: true, uniqueness: true

  # The administrative user. Capable of managing users and sites,
  # has access to all surveys.
  ADMIN = Role.find_or_create_by(name: "Admin")
end

# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

