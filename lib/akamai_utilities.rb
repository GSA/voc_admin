module AkamaiUtilities
  require 'logger'
  def flush_akamai(urls)

    logger = Logger.new('log/Akamai.log')
    logger.level = Logger::WARN

    auth = {:username => AKAMAI_CONFIG['user_name'], :password => AKAMAI_CONFIG['password']}
    request_body = {
      :type => 'arl',
      :action => 'remove',
      :domain => AKAMAI_CONFIG['domain'],
      :objects => urls
    }.to_json

    logger.warn("#{Time.now} - Requesting Akamai cache purge: #{request_body}")

     unless AKAMAI_CONFIG['development_mode']
      response = HTTParty.post(AKAMAI_CONFIG['base_uri'].to_str,
        :basic_auth => auth,
        :headers => { 'Content-Type' => 'application/json' },
        :body => request_body
      )
      begin
        parsed_response = JSON.parse(response.body)
        httpresponse = parsed_response['httpStatus']
        logger.warn(Time.now)
        logger.warn(parsed_response)
        httpresponse == 201
      rescue JSON::ParserError
        logger.error($!)
        return false
      end

    end
  end
end

# 1.  dont forget to include AkamaiUtilities

# 2.  Create load_app_config.rb in initializers that has these entries.
#   APP_CONFIG = YAML.load_file("#{Rails.root}/config/app_config.yml")[Rails.env]
#   AKAMAI_CONFIG = YAML.load_file("#{Rails.root}/config/akamai_config.yml")[Rails.env]

# 3.  Create a akamai_config.yml file that has these entries.
# development:
#   user_name: 'email@ctacorp.com'
#   password: 'password'
#   base_uri: 'https://api.ccu.akamai.com/ccu/v2/queues/default'
#   domain: 'staging'

# test:
#   #host: localhost:3000
#   user_name: 'email@ctacorp.com'
#   password: 'password'
#   base_uri: 'https://api.ccu.akamai.com/ccu/v2/queues/default'
#   domain: 'staging'

# production:
#   user_name: 'email@ctacorp.com'
#   password: 'password'
#   base_uri: 'https://api.ccu.akamai.com/ccu/v2/queues/default'
#   domain: 'production'

# 4. Create a app_config.yml file that has these entries.
#   development:
#   host: localhost:3000

#   test:
#   host: http://stage-voc.cloud.hhs.gov.edgesuite-staging.net

#   production:
#   host: yourserver.domain.local
