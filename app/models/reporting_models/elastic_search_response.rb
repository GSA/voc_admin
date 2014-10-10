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
    reportable_survey_response["answers"].try(:each) do |key,value|
      reportable_survey_response["df_#{key}"] = value
    end
    reportable_survey_response.delete("answers")
    reportable_survey_response
  end

end
