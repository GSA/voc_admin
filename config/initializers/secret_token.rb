secret_token_loaded = false

begin
  require 'yaml_erb_loader'

  SecretConfig = YamlErbLoader.load_from_config("#{Rails.root}/config/secret_settings.yml")

  unless SecretConfig.blank? or (token = SecretConfig["secret"]).nil?
    CommentToolApp::Application.config.secret_token = token
    secret_token_loaded = true
  end
rescue
end

unless secret_token_loaded
  raise "Missing configuration file for secret key settings (config/secret_settings.yml) #{$!}"
end
