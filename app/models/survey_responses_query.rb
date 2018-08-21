class SurveyResponsesQuery
  attr_accessor :params, :survey_version, :custom_view, :options

  def initialize(survey_version, custom_view = nil, params = {}, options = {})
    @params = params
    @survey_version = survey_version
    @custom_view = custom_view
    @options = options || {}
  end

  def search
    if advanced_search?
      @search_criteria = SurveyResponseSearch.new(params[:search])
    end

    ElasticSearchResponse.search(
      survey_version_id,
      search_params,
      responses_order,
      options
    )
  end

  def count
    results, _ = search
    results['hits']['total']
  end

  # Calculate the proper ordering of the SurveyResponse grid. Order of precedence:
  #   Explicit query parameter.
  #   Created By date or Page Url fields.
  #   Custom View.
  #   Default to Created By date.
  def responses_order
    if custom_view? && params[:order_column].blank?
      custom_view.sorted_display_field_custom_views.inject({}) do |hash, s|
        hash.merge elastic_sort("df_#{s.display_field_id}.raw", s.sort_direction)
      end
    else # fall back on date if we have no other recourse
      elastic_sort(order_column, order_dir)
    end
  end

  def custom_view?
    custom_view.present?
  end

  def order_dir
    %w(asc desc).include?(params[:order_dir].try(:downcase)) ?
      params[:order_dir].downcase : 'desc'
  end

  def order_column
    if column_id = survey_version.display_fields.find_by_name(params[:order_column]).try(:id)
      "df_#{column_id}.raw"
    else
      %w(id created_at page_url device).include?(params[:order_column]) ? params[:order_column] : 'created_at'
    end
  end

  def search_criteria
    SurveyResponseSearch.new(search_params) if advanced_search?
  end

  def search_params
    params[:search].presence || params[:simple_search].presence
  end

  def survey_version_id
    survey_version.id
  end

  def advanced_search?
    params[:search].present?
  end

  def elastic_sort(column, sort_direction)
    { column => { "order" => sort_direction, "ignore_unmapped" => true } }
  end
end
