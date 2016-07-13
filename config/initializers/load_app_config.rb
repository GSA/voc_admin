require 'yaml_erb_loader'

APP_CONFIG = YamlErbLoader.load_from_config("#{Rails.root}/config/app_config.yml")[Rails.env]
AKAMAI_CONFIG = YamlErbLoader.load_from_config("#{Rails.root}/config/akamai_config.yml")[Rails.env]

Resque.redis = APP_CONFIG['redis'] || "localhost:6379"
Resque.redis.namespace = "voc_#{Rails.env[0]}"
Redis.current = Redis::Namespace.new(Resque.redis.namespace, :redis => Resque.redis.redis)
Resque::Plugins::Status::Hash.expire_in = (APP_CONFIG['redis-expire'] || "86400" ).to_i

