# New:
# 
#   am = OpenAm.new(request)
#   if am.authenticate
#     if user = User.find_by_hhs_id(am.user_id)
#       UserSession.create(user,true)
#       redirect_back_or_default surveys_path              
#     else
#       render :unauthorized
#     end
#   else
#     redirect_to SSO_OPTIONS['opensso_id_location']
#   end
#
# Destroy:
#
#   flash[:notice] = "Logout successful"
#   current_user_session.destroy if current_user_session
#
#   am = OpenAm.new(request)
#   am.logout
#
#   redirect_to SSO_OPTIONS['opensso_id_location']


class OpenAm
  include HTTParty

  # Base URL for the AMS SSO calls
  base_uri SSO_OPTIONS['opensso_sp_location']

  # Cookie name used by AMS SSO (currently: WCDAMS)
  COOKIE_NAME = SSO_OPTIONS['cookie_name']

  # AMS SSO endpoints
  VALIDATE_TOKEN_PATH = "/identity/isTokenValid"
  USER_ATTRIBUTES_PATH = "/identity/attributes"
  LOGOUT_PATH = "/identity/logout"
  
  # Upon authentication, there's either an HHS ID or a
  # reason why there isn't
  attr_accessor :user_id, :failure_reason

  # Excuses...
  FAILURE_REASON_COOKIE = :cookie
  FAILURE_REASON_TOKEN = :token
  FAILURE_REASON_ID = :id

  # Capture the HTTP Request object
  def initialize(request)
    @request = request
  end

  # ENDPOINT: authenticate
  def authenticate
    
    # 1. Is there a cookie?
    unless token_cookie
      @failure_reason = FAILURE_REASON_COOKIE
      return false
    end

    # 2. Is the cookie's token valid on AMS?
    unless validate_token
      @failure_reason = FAILURE_REASON_TOKEN
      return false
    end

    @user_id = user_hhs_id

    # 3. Is there an HHS ID to return?
    # (safety: fail if we don't fetch HHS ID properly;
    # this prevents looking up User by nil hhs_id)
    unless @user_id.present?
      @failure_reason = FAILURE_REASON_ID
      return false
    end

    # Authenticated!  @user_id will now return a sane value (probably)
    true
  end

  # ENDPOINT: logout
  def logout
    # Call back to AMS to invalidate the token
    self.class.cookies({ COOKIE_NAME => token_cookie })
    self.class.post(LOGOUT_PATH, {:subjectid => token_cookie})
  end

  private

  # Retrieves the cookie from the HTTP Request
  def token_cookie
    @token_cookie ||= CGI.unescape(@request.cookies.fetch(COOKIE_NAME, nil).to_s.gsub('+', '%2B')).presence
  end

  # Checks the cookie's token with AMS
  def validate_token
    response = self.class.get("#{VALIDATE_TOKEN_PATH}?tokenid=#{token_cookie}", {})
    response.body.split('=').last.strip === 'true'
  end

  # Gets the valid user's details and plucks HHS ID
  def user_hhs_id
    self.class.cookies({ COOKIE_NAME => token_cookie })
    response = self.class.post(USER_ATTRIBUTES_PATH, {:subjectid => token_cookie})

    attribute_name = ''
    opensso_user = Hash.new

    lines = response.body.split(/\n/)
    lines.each do |line|
      if line.match(/^userdetails.attribute.name=/)
        attribute_name = line.gsub(/^userdetails.attribute.name=/, '').strip
      elsif line.match(/^userdetails.attribute.value=/)
        opensso_user[attribute_name] = line.gsub(/^userdetails.attribute.value=/, '').strip
      end
    end

    opensso_user['employeenumber']
  end
end
