# mailer_config.rb
# Read ActionMailer configuration options from mailer_settings.yml
#
# For more information about which settings may be set on
# ActionMailer::Base go to:
# http://api.rubyonrails.org/classes/ActionMailer/Base.html
#
#
# Example mailer_settings.yml layout
#
# <Rails Environment>:
#   raise_delivery_errors: false
#   default_url_options: {:host => 'example.com'}
#   delivery_method: <:smtp|:file|:send_mail>
#   smtp_settings: { :address: <outgoing mail server>,
#                    :port: <port>,
#                    :domain: <sending domain>,
#                    :user_name: <username>,
#                    :password: <password>,
#                    :authentication: <authentication type> }
#   sendmail_settings: { :location: <location>,
#                        :arguments: <command-line arguments> }
#   file_settings: { :location: <directory to write emails> }

begin
  require 'yaml_erb_loader'

  MailConfig = YamlErbLoader.load_from_config("#{Rails.root}/config/mailer_settings.yml")[Rails.env]

  unless MailConfig.blank?
    MailConfig.each_pair do |key, value|
      ActionMailer::Base.send("#{key}=", value)
    end
  end
rescue
  raise "Missing configuration file for mail settings (config/mailer_settings.yml) #{$!}"
end
