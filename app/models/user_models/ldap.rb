class Ldap
  attr_accessor :ldap, :username, :password

  def initialize(username,password)
    @username = username
    @password = password
    authenticate_admin!
  end

  def valid_connection?
    true
  end

  def valid_user?
    true
  end

  protected

  def authenticate_admin!
  end
end