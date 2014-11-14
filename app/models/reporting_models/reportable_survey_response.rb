class ReportableSurveyResponse
  include Mongoid::Document

  #persist exact same data to elastic_search
  after_save :elastic_search_persist

  field :survey_id, type: Integer
  field :survey_version_id, type: Integer
  field :survey_response_id, type: Integer

  field :created_at, type: DateTime
  field :page_url, type: String
  field :device, type: String

  field :answers, type: Hash
  field :raw_answers, type: Hash

  def elastic_search_persist
    ElasticSearchResponse.create!(self)
  end

  def self.simple_search(passed_scope, search_term)
    df_ids = passed_scope.first.answers.keys
    passed_scope = passed_scope.any_of(
      df_ids.map { |df_id|
        { "answers.#{df_id}" => /#{search_term}/i}
      }.concat([
        {"page_url" => /#{search_term}/i},
        {"device" => /#{search_term}/i}
      ])
    )
  end

end
