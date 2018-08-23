class Elasticsearch::SearchCriteria
  attr_accessor :criteria_hash

  def initialize(criteria_hash)
    @criteria_hash = criteria_hash
  end

  def exclude_filter?
    criteria_hash.fetch('include_exclude') == '0'
  end

  def value
    @value ||= if date_search?
      parse_date_in_local_time criteria_hash.fetch('value', nil).try(:chomp)
    else
      criteria_hash.fetch('value', nil).try(:chomp)
    end
  end

  def column
    @column ||= criteria_hash.fetch('display_field_id')
  end

  def date_search?
    column == 'created_at'
  end

  def id_search?
    column == "survey_response_id"
  end

  def time_string
    @time_string ||= if /\A\d{1,2}\/\d{1,2}\/\d{4}\s\d{2}:\d{2}:\d{2}\z/.match(criteria_hash.fetch('value', nil))
      "%m/%d/%Y %H:%M:%S"
    elsif /\A\d{1,2}\/\d{1,2}\/\d{4}\s\d{2}:\d{2}\z/.match(criteria_hash.fetch('value', nil))
      "%m/%d/%Y %H:%M"
    elsif /\A\d{1,2}\/\d{1,2}\/\d{4}\z/.match(criteria_hash.fetch('value', nil))
      '%m/%d/%Y'
    end
  end

  def clause_join
    @clause_join ||= criteria_hash.fetch('clause_join', nil)
  end

  def condition
    @condition ||= criteria_hash.fetch('condition', nil)
  end

  def filter_proc
    if date_search?
      DATE_CONDITIONS[condition].call(column, value, time_string)
    elsif id_search?
      ID_CONDITIONS[condition].call(column, value)
    else
      CONDITIONS[condition].call(column, value)
    end
  end

  def to_a
    [clause_join, filter_proc]
  end

  def parse_date_in_local_time(date_str)
    zone = "Eastern Time (US & Canada)"
    begin
      if date_str =~ /\A(\d{1,2})\/(\d{1,2})\/(\d{4})(.*)\z/
        date_str = "#{$3}-#{$1}-#{$2}#{$4}"
      end
      ActiveSupport::TimeZone[zone].parse(date_str)
    rescue
      date_str
    end
  end

  DATE_CONDITIONS = {
    "equals" => proc {|column, value, time_string|
      case time_string
      when "%m/%d/%Y"
        {
          "range" => {
            column => {
              "gte" => value.beginning_of_day.utc,
              "lte" => value.end_of_day.utc
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
          "range" => { column => { "gt" => value.end_of_day.utc } }
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
          "range" => { column => { "lt" => value.beginning_of_day.utc } }
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

  ID_CONDITIONS = {
    "equals" => proc {|column, value|
      {
        "query" => {
          "match" => { column => value }
        }
      }
    },
    "contains" => proc { |column, value|
      {
        "regexp" => { column => ".*#{value}.*" }
      }
    },
    "begins_with" => proc {|column, value|
      {
        "regexp" => { column => "#{value}.*" }
      }
    },
    "ends_with" => proc {|column, value|
      {
        "regexp" => { column => ".*#{value}" }
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
end
