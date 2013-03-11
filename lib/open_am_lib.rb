#    https://wcdsso.cloud.hhs.gov
#    Dyenell.Alfaro
#    P@ssw0rd!234

module OpenAmLib
  
  #Module's class level stuff
  @@openam_instance = nil

  def self.openam_instance=(openam_instance)
    @@openam_instance = openam_instance
  end 
  
  def self.openam_instance
    @@openam_instance
  end
  
  #define the OpenAM class
  class OpenAm
    include HTTParty
      
    attr_accessor :raw_config

    #OpenAM end points
    COOKIE_NAME_FOR_TOKEN = "/identity/getCookieNameForToken"
    IS_TOKEN_VALID = "/identity/isTokenValid"
    USER_ATTRIBUTES = "/identity/attributes"
    LOGOUT = "/identity/logout"
    
    def initialize(config_path=nil)
      path = config_path || "#{Rails.root}/config/sso_config.yml"
      @raw_config = YAML.load(File.read(path))
      self.class.base_uri raw_config['opensso_sp_location']
    end
    
    def get_cookie_name_for_token
      response = self.class.post(COOKIE_NAME_FOR_TOKEN, {})
      response.body.split('=').last.strip
    end
  
    def get_token_cookie(request, token_cookie_name)
      token_cookie = CGI.unescape(request.cookies.fetch(token_cookie_name, nil).to_s.gsub('+', '%2B'))
      token_cookie != '' ? token_cookie : nil    
    end
  
    def validate_token(token)
      response = self.class.get("#{IS_TOKEN_VALID}?tokenid=#{token}", {})
      response.body.split('=').last.strip == 'true'
    end
  
    def get_opensso_user(token_cookie_name, token)
      self.class.cookies({ token_cookie_name => token })
      response = self.class.post("#{USER_ATTRIBUTES}", {:subjectid => token})
        
      opensso_user = Hash.new{ |h,k| h[k] = Array.new }
      attribute_name = ''
  
      lines = response.body.split(/\n/)
      lines.each do |line|
        if line.match(/^userdetails.attribute.name=/)
          attribute_name = line.gsub(/^userdetails.attribute.name=/, '').strip
        elsif line.match(/^userdetails.attribute.value=/)
          opensso_user[attribute_name] << line.gsub(/^userdetails.attribute.value=/, '').strip
        end
      end
      
      opensso_user
    end
    
    def get_group(token_cookie_name, token, group)
      []
    end
  
    def logout_opensso_user(token_cookie_name, token)
      self.class.cookies({ token_cookie_name => token })
      self.class.post("#{LOGOUT}", {:subjectid => token})
    end
    
    def valid_token?(token)
      token != nil and self.validate_token(token)
    end
    
  end
  
  #define instance level stuff for controller include
  
  attr_accessor :token_cookie_name, :token_cookie, :token_groups, :sso_user
  
  def token_cookie_name
    @token_cookie_name ||= OpenAmLib.openam_instance.get_cookie_name_for_token
  end
  
  def token_cookie
    @token_cookie ||= OpenAmLib.openam_instance.get_token_cookie(request, token_cookie_name)
  end
  
  def token_groups
    @token_groups ||= OpenAmLib.openam_instance.get_groups(token_cookie_name,token_cookie)
  end
  
  def sso_user
    @sso_user ||=  OpenAmLib.openam_instance.get_opensso_user(token_cookie_name, token_cookie)
  end
  
  def sso_user_hhs_id
    sso_user['employeenumber']
  end
  
  #Used for responses
  OpenAmResponseStruct = Struct.new(:code, :message) do
    alias_method :to_ary, :to_a
  end
  
  #returns struct with first arg being boolean, second being the attributes if token was valid
  def authenticate_token(request, groups = nil, redirect=nil)
   res = OpenAmResponseStruct.new(false,nil)
   
   #validate_token
   begin
    raise "<Invalid Token>" unless OpenAmLib.openam_instance.valid_token?(token_cookie)
    raise "<Invalid Group>" if !groups.nil? && !validate_group(groups).code
    
    res = true, sso_user
   rescue Exception => msg
     if redirect == true || OpenAmLib.openam_instance.raw_config["redirect"] == true
       #not valid: redirect to logon
       url = OpenAmLib.openam_instance.raw_config['wcd_portal'] + "?goto=" + OpenAmLib.openam_instance.raw_config['default_goto']
       redirect_to (url)
       res = false,"#{msg}:<redirecting to logon>"
     else
       res = false, msg
     end
   end
   res
  end
  
  def validate_group(groups)
    res = OpenAmResponseStruct.new(false,nil)
    groups = [groups] unless groups.class != Array
    begin
      groups.each do |group|
        raise "<invalid group - #{group} >" unless token_groups.includes? group
      end
      res true, groups
    raise Exception => msg
      res false, msg
    end
  end
  
  def logout(redirect=false)
    OpenAmLib.openam_instance.logout_opensso_user(token_cookie_name, token_cookie)
    if redirect == true || OpenAmLib.openam_instance.raw_config["redirect"] == true
      redirect_to OpenAmLib.openam_instance.raw_config['ams_home']
    end
  end
end