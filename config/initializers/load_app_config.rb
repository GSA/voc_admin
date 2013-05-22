APP_CONFIG = YAML.load_file("#{Rails.root}/config/app_config.yml")[Rails.env]

Resque.redis = APP_CONFIG['redis'] || "localhost:6379"
Resque::Plugins::Status::Hash.expire_in = (APP_CONFIG['redis-expire'] || "86400" ).to_i