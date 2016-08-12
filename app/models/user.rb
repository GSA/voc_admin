# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# A system user.  Ties into Devise.
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :omniauthable, :trackable, :timeoutable, omniauth_providers: [ :saml ]

  attr_accessible :f_name, :l_name, :password, :email, :password_confirmation,
                  :site_ids, :role_id, :username, :fullname, :organization_id

  attr_accessor :first_name, :last_name, :password_confirmation

  has_many :site_users
  has_many :sites, through: :site_users
  belongs_to :role
  belongs_to :organization

  validates :email, :f_name, :l_name, :username, presence: true

  before_save :set_fullname

  scope :listing, -> { order("fullname ASC") }
  scope :search, ->(q = nil) {
    where("CONCAT(f_name, ' ', l_name) LIKE ?", "%#{q}%") unless q.blank?
  }

  def self.from_omniauth(params)
    User.find_by(email: params['uid'])
  end

  # Gets all the surveys a user has access to.  Admins are able to see all
  # surveys; users are only able to see surveys which belong to sites they have
  # access to.
  #
  # @return [ActiveRecord::Relation] surveys the user has access to
  def surveys
    if admin?
      Survey.all
    else
      Survey.includes(site: :site_users).where(site_users: { user_id: id })
    end
  end

  # Makes the email login input value case insensitive.
  #
  # @param [String] umail email from the login form to downcase
  def email=(umail)
    write_attribute(:email, umail.try(:mb_chars).try(:downcase))
  end

  # Check whether the user is an admin.
  #
  # @return [Boolean] true if the user is an admin, false otherwise
  def admin?
    role_id.present? && role_id == Role::ADMIN.id
  end

  def set_fullname
    self.fullname = "#{f_name} #{l_name}"
  end
end

# == Schema Information
#
# Table name: users
#
#  id                :integer          not null, primary key
#  locked            :boolean
#  email             :string(255)      not null
#  crypted_password  :string(255)
#  password_salt     :string(255)
#  persistence_token :string(255)      not null
#  created_at        :datetime
#  updated_at        :datetime
#  role_id           :integer
#  hhs_id            :string(50)
#  last_request_at   :datetime
#
