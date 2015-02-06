class ElasticsearchAdvancedSearch
  attr_accessor :search_params

  def initialize(search_params)
    @search_params = search_params
  end

  def filter_object
    @search_params['criteria'].map do |k, criteria|
      Elasticsearch::SearchCriteria.new(criteria).to_a
    end.inject({}) {|filters, f|
      if f.first == nil
        f.last
      else
        build_filter(filters, *f)
      end
    }
  end

  def build_query
    {
      "filter" => filter_object
    }
  end

  def build_filter(left_side, bool_operator, right_side)
    if bool_operator == "AND"
      {
        "bool" => {
          "must" => [
            left_side,
            right_side
          ]
        }
      }
    else
      {
        "bool" => {
          "should" => [
            left_side,
            right_side
          ]
        }
      }
    end
  end

end
