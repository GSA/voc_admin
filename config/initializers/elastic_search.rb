require 'elasticsearch'
config = YAML.load_file("#{Rails.root}/config/app_config.yml")[Rails.env]
ELASTIC_SEARCH_HOSTS = config["elastic-search-hosts"] || "localhost:9200"

ELASTIC_SEARCH_CLIENT = Elasticsearch::Client.new({
  hosts: ELASTIC_SEARCH_HOSTS,
  log: true
})

unless ELASTIC_SEARCH_CLIENT.indices.exists index: 'survey_responses'
  ELASTIC_SEARCH_CLIENT.indices.create index: 'survey_responses', body: {
    mappings: {
      "_default_" => {
        dynamic_templates: {
          str: {
            match: "^qc_.*|^df_.*|^page_url$|^device$",
            match_mapping_type: "string",
            match_pattern: "regex",
            mapping: {
              type: "string",
              fields: {
                raw: {type: "string", index: "not_analyzed"}
              }
            }
          },
          created_at: {
            match: "created_at",
            match_mapping_type: "dateOptionalTime",
            mapping: {
              type: "dateOptionalTime",
              fields: {
                raw: {type: "dateOptionalTime", index: "not_analyzed"}
              }
            }
          }
        }
      }
    }
  }
end

