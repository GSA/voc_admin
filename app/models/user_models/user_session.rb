# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# The Authlogic user session.  Maintains user state.
class UserSession < Authlogic::Session::Base
  generalize_credentials_error_messages true
end