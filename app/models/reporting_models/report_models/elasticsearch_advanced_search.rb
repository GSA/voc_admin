class ElasticsearchAdvancedSearch
  attr_accessor :search_params

  def initialize(search_params)
    @search_params = search_params
  end

  def filter_object
    excludes, criterias = @search_params['criteria'].map do |k, criteria|
      Elasticsearch::SearchCriteria.new(criteria)
    end.partition {|criteria| criteria.exclude_filter? }

    not_filter = excludes.inject([]) {|must_not, exclude|
      must_not |= [exclude.filter_proc]
    }

    include_filter = criterias.map(&:to_a).inject({}) {|filters, f|
      if f.first.nil?
        f.last
      else
        build_filter(filters, *f)
      end
    }

    unless not_filter.empty?
      include_filter['bool'] ||= {}
      include_filter['bool']['must_not'] = not_filter
    end

    include_filter
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
