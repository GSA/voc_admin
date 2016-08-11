require 'elasticsearch'
ELASTIC_SEARCH_HOST = "#{APP_CONFIG['elasticsearch_hosts']}:#{APP_CONFIG['elasticsearch_port']}"
ELASTIC_SEARCH_INDEX_NAME = "survey_responses_#{Rails.env}"

puts "Connecting to Elasticsearch: #{ELASTIC_SEARCH_HOST}"

ELASTIC_SEARCH_CLIENT = Elasticsearch::Client.new({
  host: ELASTIC_SEARCH_HOST,
  log: false
})

mappings = {
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


ELASTIC_SEARCH_MAPPINGS = {
  survey_responses: {
    mappings: mappings
  },
  survey_responses_development: {
    mappings: mappings
  },
  survey_responses_production: {
    mappings: mappings
  },
  survey_responses_test: {
    mappings: mappings
  }
}

begin
  unless ELASTIC_SEARCH_CLIENT.indices.exists index: ELASTIC_SEARCH_INDEX_NAME
    ELASTIC_SEARCH_CLIENT.indices.create index: ELASTIC_SEARCH_INDEX_NAME, body: ELASTIC_SEARCH_MAPPINGS[ELASTIC_SEARCH_INDEX_NAME.to_sym]
  end
rescue Faraday::ClientError => e
  puts "Can't connect to ElasticSearch Server"
  puts e.message
  exit
end
