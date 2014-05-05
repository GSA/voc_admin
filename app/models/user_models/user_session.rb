# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# The Authlogic user session.  Maintains user state.
class UserSession < Authlogic::Session::Base
  generalize_credentials_error_messages true
  verify_password_method :valid_ldap_credentials?
  logout_on_timeout true # default is false
end