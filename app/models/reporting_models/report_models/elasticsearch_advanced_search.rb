class ElasticsearchAdvancedSearch
  attr_accessor :search_params

  def initialize(search_params)
    @search_params = search_params
  end

  def filter_object
    @search_params['criteria'].map do |k, criteria|
      value = criteria['value']
      column = criteria['display_field_id']
      date_search = column == 'created_at'
      time_string = '%m/%d/%Y' if /\d{1,2}\/\d{1,2}\/\d{4}/.match(value)
      value = parse_date_in_local_time(value) if date_search
      [
        criteria['clause_join'],
        (date_search ?
          DATE_CONDITIONS[criteria['condition']].call(
            column,
            value,
            time_string
          ) : CONDITIONS[criteria['condition']].call(
            column,
            value
          )
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

  DATE_CONDITIONS = {
    "equals" => proc {|column, value, time_string|
      case time_string
      when "%m/%d/%Y"
        {
          "range" => {
            column => {
              "gte" => value.beginning_of_day,
              "lte" => value.end_of_day
            }
          }
        }
      else
        {
          "query" => {
            "match" => { "#{column}.raw" => value }
          }
        }
      end
    },
    "greater_than" => proc {|column, value, time_string|
      case time_string
      when "%m/%d/%Y"
        {
          "range" => { column => { "gt" => value.end_of_day } }
        }
      else
        {
          "range" => { column => { "gt" => value } }
        }
      end
    },
    "less_than" => proc {|column, value, time_string|
      case time_string
      when "%m/%d/%Y"
        {
          "range" => { column => { "lt" => value.beginning_of_day } }
        }
      else
        {
          "range" => { column => { "lt" => value } }
        }
      end
    }

  }

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

  def parse_date_in_local_time(value)
    time_string = nil
    # chomp the value
    value.chomp!
    begin
      # Set the time format string based on the datetime input by the  user
      if /\d{1,2}\/\d{1,2}\/\d{4}\s\d{2}:\d{2}:\d{2}/.match(value)
        time_string = "%m/%d/%Y %H:%M:%S"
      elsif /\d{1,2}\/\d{1,2}\/\d{4}\s\d{2}:\d{2}/.match(value)
        time_string = "%m/%d/%Y %H:%M"
      elsif /\d{1,2}\/\d{1,2}\/\d{4}/.match(value)
        time_string = '%m/%d/%Y'
        return Date.strptime(value, time_string)
      else
        # Did not match a time format.  Pass on the string value.
        return value
      end

      DateTime.strptime(value + " #{Time.zone.now.formatted_offset}", time_string.chomp + " %:z").to_s
    rescue
      value
    end
  end

end
