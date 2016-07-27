require 'net/ldap'
class Ldap
  attr_accessor :ldap, :username, :password

  def initialize(username,password)
    @username = username
    @password = password
    authenticate_admin!
  end

  def valid_connection?
    return true if ENV.fetch("SKIP_LDAP_AUTHENTICATION") == "true"
    unless @ldap.bind
      Rails.logger.fatal "Unable to authenticate LDAP service account #{LDAP_CONFIG['service_user']}"
      return false
    else
      return true
    end
  end

  def valid_user?
    return true if ENV.fetch('SKIP_LDAP_AUTHENTICATION') == 'true'
    # search ldap based on given username. this is because different
    # ldap methods store it other ways. openldap = uid, ad = sAMAccountName
    filter =Net::LDAP::Filter.eq("#{LDAP_CONFIG['uid_name']}", username)
    results = @ldap.search(:base=>"#{LDAP_CONFIG['base']}",
      :filter => filter,
      :attributes=>["dn"],
      :return_result => true)
    # iff one result, authenticate that user (names should be unique after all)
    if results != nil && results != [] && results.count == 1
      @ldap.auth results.first.dn, password
      unless @ldap.bind
        Rails.logger.debug "LDAP Authentication Result: #{@ldap.get_operation_result.code}"
        Rails.logger.debug "LDAP Authentication Message: #{@ldap.get_operation_result.message}"
        return false
      else
        return true
      end
    end
  end

  protected

  def authenticate_admin!
    return User.find_by_username(username).admin? if ENV.fetch('SKIP_LDAP_AUTHENTICATION') == 'true'
    # create an administrator connection to LDAP
    @ldap = Net::LDAP.new(:host => "#{LDAP_CONFIG['host']}",
      :port => "#{LDAP_CONFIG['port']}")
    # Decides whether service_domain is needed, this is basically AD versus openldap handling
    unless LDAP_CONFIG['service_domain'].blank?
      # handle active director auth
      @ldap.auth("#{LDAP_CONFIG['service_user']}@#{LDAP_CONFIG['service_domain']}",
        LDAP_CONFIG['service_pass'])
    else
      # handle openldap auth
      @ldap.auth("cn=#{LDAP_CONFIG['service_user']},#{LDAP_CONFIG['base']}",
        LDAP_CONFIG['service_pass'])
    end
    # Log and reject access if we can not authenticate the service account
    unless @ldap.bind
      Rails.logger.fatal "Unable to authenticate LDAP service account #{LDAP_CONFIG['service_user']}"
    else
      Rails.logger.debug "Authenticated our LDAP service account"
    end
  end
end
