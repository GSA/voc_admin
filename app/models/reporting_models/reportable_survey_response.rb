class ReportableSurveyResponse
  include Mongoid::Document

  field :survey_id, type: Integer
  field :survey_version_id, type: Integer
  field :survey_response_id, type: Integer

  field :created_at, type: DateTime
  field :page_url, type: String
  field :device, type: String

  field :answers, type: Hash
  field :archived, type: Boolean, default: false
  
  default_scope where(:archived => false)

  # ORIGINALLY:
  # answers[df.id.to_s] =
  # {
  #   "type" => df.type,
  #   "text" => df.name,
  #   "order" => df.display_order.to_s,
  #   "value" => dfv.value
  # }

end
