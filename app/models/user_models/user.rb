class User < ActiveRecord::Base
  attr_accessible :f_name, :l_name, :password, :email, :password_confirmation, :site_ids, :role_id

  has_many :site_users
  has_many :sites,      :through => :site_users
  belongs_to :role

  acts_as_authentic

  validates :email,     :presence => true
  validates :f_name,    :presence => true
  validates :l_name,    :presence => true

  scope :listing,       order("l_name ASC, f_name ASC")

  def surveys
    if self.admin?
      Survey.scoped
    else
      Survey.includes(:site => :site_users).where(:site => {:site_users => { :user_id => self.id} })
    end
  end

  # make email login case insensitive
  def email=(umail)
    write_attribute(:email, umail.try(:mb_chars).try(:downcase))
  end

  def admin?
    self.role == Role::ADMIN
  end

end

# == Schema Information
#
# Table name: users
#
#  id                :integer(4)      not null, primary key
#  f_name            :string(255)     not null
#  l_name            :string(255)     not null
#  locked            :boolean(1)
#  email             :string(255)     not null
#  crypted_password  :string(255)     not null
#  password_salt     :string(255)     not null
#  persistence_token :string(255)     not null
#  created_at        :datetime
#  updated_at        :datetime
#  role_id           :integer(4)
#

