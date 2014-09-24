require 'elasticsearch'
ELASTIC_SEARCH_CONFIG = YAML.load_file("#{Rails.root}/config/app_config.yml")[Rails.env]["elastic-search-hosts"]

ELASTIC_SEARCH_CLIENT = Elasticsearch::Client.new({
  hosts: ELASTIC_SEARCH_CONFIG,
  log: true
})