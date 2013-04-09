# Direct use, authentication:
# 
# am = OpenAm.new(request)
# if am.authenticate
#   user = User.find_by_hhs_id(am.user_id)
#   if user
#     UserSession.create(user,true)
#     redirect_back_or_default surveys_path              
#   else
#     render :unauthorized
#   end
# else
#   redirect_to SSO_OPTIONS['opensso_id_location']
# end

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
  
  attr_accessor :user_id, :failure_reason

  FAILURE_REASON_COOKIE = :cookie
  FAILURE_REASON_TOKEN = :token

  def initialize(request)
    @request = request
  end

  def authenticate
    unless token_cookie
      @failure_reason = FAILURE_REASON_COOKIE
      return false
    end

    unless validate_token
      @failure_reason = FAILURE_REASON_TOKEN
      return false
    end

    @user_id = user_hhs_id
    true
  end

  def logout
    self.class.cookies({ COOKIE_NAME => token_cookie })
    self.class.post(LOGOUT_PATH, {:subjectid => token_cookie})
  end

  private

  def token_cookie
    @token_cookie ||= CGI.unescape(@request.cookies.fetch(COOKIE_NAME, nil).to_s.gsub('+', '%2B')).presence
  end

  def validate_token
    response = self.class.get("#{VALIDATE_TOKEN_PATH}?tokenid=#{token_cookie}", {})
    response.body.split('=').last.strip === 'true'
  end

  def user_hhs_id
    self.class.cookies({ COOKIE_NAME => token_cookie })
    response = self.class.post(USER_ATTRIBUTES_PATH, {:subjectid => token_cookie})

    opensso_user = {}

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
