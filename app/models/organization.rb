class Organization < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  scope :search, ->(q=nil) {
    where("organizations.name LIKE ?", "%#{q}%") unless q.blank?
  }
end
