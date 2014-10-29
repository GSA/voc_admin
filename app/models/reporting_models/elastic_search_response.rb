class ElasticSearchResponse

  def self.create!(reportable_survey_response)
    ELASTIC_SEARCH_CLIENT.index({
      index: "survey_responses",
      type: "sv_id_#{reportable_survey_response.survey_version_id}",
      id: reportable_survey_response.id,
      body: self.transform(reportable_survey_response)
    })
  end

  def self.transform(reportable_survey_response)
    reportable_survey_response = reportable_survey_response.attributes.to_hash
    reportable_survey_response["answers"].try(:each) do |key, value|
      reportable_survey_response["df_#{key}"] = value
    end
    reportable_survey_response.delete("answers")
    reportable_survey_response["raw_answers"].try(:each) do |key, value|
      reportable_survey_response["qc_#{key}"] = value
    end
    reportable_survey_response.delete("raw_answers")
    reportable_survey_response
  end

  def self.search(sv_id, search = nil, sort = "")
    args = {index: 'survey_responses', type: "sv_id_#{sv_id}", _source: "survey_response_id"}
    args[:q] = search if search.present?
    results = ELASTIC_SEARCH_CLIENT.search(args)
    ids = results["hits"]["hits"].map {|hit| hit["_source"]["survey_response_id"]}
    [results, SurveyResponse.where(id: ids).order("field(id, #{ids.join(',')})")]
  end
end
