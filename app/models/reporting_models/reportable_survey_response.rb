class ReportableSurveyResponse
  include Mongoid::Document

  #persist exact same data to elastic_search
  after_save :elastic_search_persist
  before_destroy :elastic_search_remove

  field :survey_id, type: Integer
  field :survey_version_id, type: Integer
  field :survey_response_id, type: Integer

  field :created_at, type: DateTime
  field :page_url, type: String
  field :device, type: String

  field :raw_answers, type: Hash
  field :answers, type: Hash
  field :archived, type: Boolean, default: false

  default_scope -> { where(:archived => false) }

  def elastic_search_persist
    ElasticSearchResponse.create!(self)
  rescue
    puts $!
  end

  def elastic_search_remove
    ElasticSearchResponse.delete(self)
  end

end
