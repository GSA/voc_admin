require 'elasticsearch'
config = YAML.load_file("#{Rails.root}/config/app_config.yml")[Rails.env]
ELASTIC_SEARCH_HOSTS = config["elastic-search-hosts"] || "localhost:9200"

ELASTIC_SEARCH_CLIENT = Elasticsearch::Client.new({
  hosts: ELASTIC_SEARCH_HOSTS,
  log: false
})

ELASTIC_SEARCH_MAPPINGS = {
  survey_responses: {
    mappings: {
      "_default_" => {
        dynamic_templates: [
          {
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
            }
          },
          {
            created_at: {
              match: "created_at",
              match_mapping_type: "date",
              mapping: {
                type: "date",
                format: "dateOptionalTime",
                fields: {
                  raw: {type: "date", format: "dateOptionalTime", index: "not_analyzed"}
                }
              }
            }
          },
          {
            ids: {
              match: "^survey.*id$",
              match_mapping_type: "long",
              match_pattern: "regex",
              mapping: {
                type: "long"
              }
            }
          }
        ]
      }
    }
  }
}

unless ELASTIC_SEARCH_CLIENT.indices.exists index: 'survey_responses'
  ELASTIC_SEARCH_CLIENT.indices.create index: 'survey_responses', body: ELASTIC_SEARCH_MAPPINGS[:survey_responses]
end

