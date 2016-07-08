class Organization < ActiveRecord::Base
  has_many :users, dependent: :nullify

  validates :name, presence: true, uniqueness: true, length: {
    maximum: 255
  }

  scope :search, ->(q=nil) {
    where("organizations.name LIKE ?", "%#{q}%") unless q.blank?
  }
end
