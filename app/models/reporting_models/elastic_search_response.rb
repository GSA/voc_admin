class ElasticSearchResponse

  def self.create!(reportable_survey_response)
    ELASTIC_SEARCH_CLIENT.index({
      index: ELASTIC_SEARCH_INDEX_NAME,
      type: "sv_id_#{reportable_survey_response.survey_version_id}",
      id: reportable_survey_response.id,
      body: self.transform(reportable_survey_response)
    })
  end

  def self.transform(reportable_survey_response)
    reportable_survey_response = reportable_survey_response.attributes.to_hash
    reportable_survey_response["_id"] = reportable_survey_response["_id"].to_s
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

  def self.search(survey_version_id, search = nil, sort = nil, options = {})
    args = {
      index: ELASTIC_SEARCH_INDEX_NAME,
      type: "sv_id_#{survey_version_id}",
      body: {}
    }
    if search.blank?
      args[:body] = empty_search
    elsif search.is_a?(String)
      args[:body] = query_string_search(search)
    else
      args[:body] ||= {}
      args[:body][:query] ||= {}
      args[:body][:query][:filtered] = ElasticsearchAdvancedSearch.new(search).build_query
    end
    if sort.present?
      args[:body]["sort"] = sort
    end

    args[:body][:size] = options[:size] || SurveyResponse.default_per_page
    args[:body][:from] = (options[:page] || 0) * args[:body][:size]

    results = ELASTIC_SEARCH_CLIENT.search args
    ids = results['hits']['hits'].map {|hit| hit['_source']['survey_response_id']}
    responses = SurveyResponse.where(id: ids)

    # NOTE: This will only work with MySQL due to the field() method.  We can't
    # use the field method if ids is empty.  It will cause an error in the MySQL
    # statement, so we have to wrap the order clause in a guard statement.
    if !ids.empty?
      responses = responses.order("field(id, #{ids.join(',')})")
    end
    [results, responses]
  end

  def self.delete(reportable_survey_response)
    ELASTIC_SEARCH_CLIENT.delete index: ELASTIC_SEARCH_INDEX_NAME, type: "sv_id_#{survey_version_id}",
      id: reportable_survey_response.id
  end

  private

  def self.empty_search
    {
      "sort" => {
        "created_at" => { "order" => "asc", "ignore_unmapped" => true }
      },
      "query" => {
        "match_all" => {}
      }
    }
  end

  def self.query_string_search(search_query)
    {
      "query" => {
        "query_string" => {
          "query" => "*#{search_query}*"
        }
      }
    }
  end
end
