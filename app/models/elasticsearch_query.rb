class ElasticsearchQuery
  attr_accessor :search_options, :survey_version_id, :options

  EMPTY_SEARCH = {
    "query" => {
      "match_all" => {}
    }
  }

  def initialize(survey_version_id, search_options = nil, options = {})
    @search_options = search_options
    @survey_version_id = survey_version_id
    @options = options || {}
  end

  def args
    @args ||= begin
      search_criteria = {
        index: ELASTIC_SEARCH_INDEX_NAME,
        type: "sv_id_#{survey_version_id}",
        body: {}
      }
      if search_options.blank?
        search_criteria[:body] = EMPTY_SEARCH
      elsif search_options.is_a?(String)
        search_criteria[:body] = query_string_search(search_options)
      else
        search_criteria[:body] ||= {}
        search_criteria[:body][:query] ||= {}
        search_criteria[:body][:query][:filtered] = ElasticsearchAdvancedSearch.new(search_options).build_query
      end

      search_criteria
    end
  end

  def search(opts = {})
    results = ELASTIC_SEARCH_CLIENT.search(search_criteria.deep_merge(opts))
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

  def in_batches(batch_size = limit)
    return to_enum(__callee__, batch_size) unless block_given?
    num_batches = (count / batch_size.to_f).ceil
    num_batches.times do |batch|
      _, responses = search({body: {from: (batch_size * batch), size: batch_size}})
      yield responses
    end
  end

  def reportable_survey_responses_in_batches(batch_size = limit)
    return to_enum(__callee__, batch_size) unless block_given?
    num_batches = (count / batch_size.to_f).ceil
    num_batches.times do |batch|
      es_results, _ = search({body: {from: (batch_size * batch), size: batch_size}})
      reportable_survey_responses = ReportableSurveyResponse
        .where(survey_version_id: survey_version_id)
        .in(survey_response_id: es_results['hits']['hits'].map {|hit| hit['_source']}
        .map {|hit| hit['survey_response_id']})
      yield reportable_survey_responses.to_a
    end
  end

  def each_page
    return to_enum(__callee__) unless block_given?
    total_pages.times do |page|
      _, responses = search({from: page * limit})
      yield responses
    end
  end

  def search_criteria
    {
      body: {
        sort: sort,
        size: limit,
        from: offset
      }
    }.deep_merge(args)
  end

  def total_pages
    (count / limit.to_f).ceil
  end

  def count
    ELASTIC_SEARCH_CLIENT.count(args).fetch('count')
  end

  def limit
    (options[:size] || SurveyResponse.default_per_page)
  end

  def offset
    (options[:page] || 0) * limit
  end

  def sort
    {
      "created_at" => { "order" => "desc" }
    }
  end

  private
  def query_string_search(search_query)
    {
      "query" => {
        "query_string" => {
          "query" => "*#{search_query}*"
        }
      }
    }
  end
end
