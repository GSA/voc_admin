class ElasticsearchAdvancedSearch
  attr_accessor :search_params

  def initialize(search_params)
    @search_params = search_params
  end

  def filter_object
    @search_params['criteria'].map do |k, criteria|
      [
        criteria['clause_join'],
        CONDITIONS[criteria['condition']].call(
          criteria['display_field_id'],
          criteria['value']
        )
      ]
    end.inject({}) {|filters, f|
      if f.first == nil
        f.last
      else
        build_filter(filters, *f)
      end
    }
  end

  CONDITIONS = {
    "equals" => proc {|column, value|
      {
        "query" => {
          "match" => { "#{column}.raw" => value }
        }
      }
    },
    "contains" => proc { |column, value|
      {
        "regexp" => { "#{column}.raw" => ".*#{value}.*" }
      }
    },
    "begins_with" => proc {|column, value|
      {
        "regexp" => { "#{column}.raw" => "#{value}.*" }
      }
    },
    "ends_with" => proc {|column, value|
      {
        "regexp" => { "#{column}.raw" => ".*#{value}" }
      }
    },
    "greater_than" => proc {|column, value|
      {
        "range" => { column => { "gt" => value } }
      }
    },
    "less_than" => proc { |column, value|
      {
        "range" => { column => { "lt" => value } }
      }
    }
  }

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
