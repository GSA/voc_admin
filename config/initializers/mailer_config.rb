MailConfig = YAML.load_file("#{Rails.root}/config/smtp_settings.yml")[Rails.env]

MailConfig.each_pair do |key, value|
  ActionMailer::Base.send("#{key}=", value)
end