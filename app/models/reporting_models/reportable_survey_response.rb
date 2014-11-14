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

end
