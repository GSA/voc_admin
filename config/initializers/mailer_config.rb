begin
  MailConfig = YAML.load_file("#{Rails.root}/config/mailer_settings.yml")[Rails.env]

  MailConfig.each_pair do |key, value|
    ActionMailer::Base.send("#{key}=", value)
  end
rescue
  raise "Missing configuration file for mail settings (config/mailer_settings.yml)"
end