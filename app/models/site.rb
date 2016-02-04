# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# A distinct website from which Surveys will be hosted.
class Site < ActiveRecord::Base
  attr_accessible :name, :url, :description

  has_many :surveys
  has_many :site_users
  has_many :users, :through => :site_users

  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :url, presence: true, uniqueness: true, length: { maximum: 255 }, url: true
  validates :description, presence: true, length: { maximum: 4000 }

  scope :search, ->(q = nil) {
    where("sites.name LIKE ?", "%#{q}%") unless q.blank?
  }
end

# == Schema Information
#
# Table name: sites
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  url         :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

