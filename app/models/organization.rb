class Organization < ActiveRecord::Base
  has_many :users, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  scope :search, ->(q=nil) {
    where("organizations.name LIKE ?", "%#{q}%") unless q.blank?
  }
end
