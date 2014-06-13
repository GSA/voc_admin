class ReportableSurveyResponseSearch
  attr_accessor :criteria, :conditions, :parameters, :clause_joins

  CONDITIONS = {
    'equals' => proc {|base_scope, field_name, value, or_clause = false|
        base_scope.where(field_name => value)
    },
    'contains' => proc {|base_scope, field_name, value, or_clause = false|
        base_scope.where(field_name => Regexp.new("#{value}"))
    },
    'begins_with' => proc {|base_scope, field_name, value, or_clause = false|
        base_scope.where(field_name => Regexp.new("^#{value}"))
    },
    'ends_with' => proc {|base_scope, field_name, value, or_clause = false|
        base_scope.where(field_name => Regexp.new("#{value}$"))
    },
    'less_than' => proc {|base_scope, field_name, value, or_clause = false|
        base_scope.where( :"#{field_name}".lt => value)
    },
    'greater_than' => proc {|base_scope, field_name, value, or_clause = false|
        base_scope.where( :"#{field_name}".gt => value)
    }
  }

  NEGATION_CONDITIONS = {
    'equals' => proc {|base_scope, field_name, value| base_scope.where(field_name.to_sym.ne => value) },
    'less_than' => proc {|base_scope, field_name, value| base_scope.where(:"#{field_name}".gte => value) },
    'greater_than' => proc {|base_scope, field_name, value| base_scope.where(:"#{field_name}".lte => value) }
  }

  def initialize(attribs = nil)
    @criteria = attribs['criteria']
    @conditions = []
    @parameters = []
    @clause_joins = []
  end

  def search(base_scope = nil)
    base_scope ||= ReportableSurveyResponse.scoped

    criteria.each do |k, criterion|
      query_hash = criterion['include_exclude'] == '0' ? NEGATION_CONDITIONS : CONDITIONS
      condition = criterion['condition']
      value = criterion['value']
      join_clause = criterion['join_clause']

      if %w( survey_responses.page_url survey_responses.device ).include?(criterion['display_field_id'])
        search_field = criterion['display_field_id'].split('.').last
      elsif criterion['display_field_id'] == 'survey_responses.created_at'
        value = parse_date_value(criterion['value'])
        search_field = 'created_at'
      else
        search_field = "answers.#{criterion['display_field_id']}"
      end

      base_scope = query_hash[condition].call(base_scope, search_field, value, join_clause == 'OR')
    end

    base_scope
  end

  private

  def parse_date_value(value)
    # chomp the value
    value.chomp!

    # Set the time format string based on the datetime input by the  user
    if /\d{1,2}\/\d{1,2}\/\d{4}\s\d{2}:\d{2}:\d{2}/.match(value)
      time_string = "%m/%d/%Y %H:%M:%S"
    elsif /\d{1,2}\/\d{1,2}\/\d{4}\s\d{2}:\d{2}/.match(value)
      time_string = "%m/%d/%Y %H:%M"
    elsif /\d{1,2}\/\d{1,2}\/\d{4}/.match(value)
      time_string = '%m/%d/%Y'
    end

    Time.strptime(value + " #{Time.zone.now.formatted_offset}", time_string.chomp + " %:z")
  end
end

# {
  # "search"=> {
  # { "criteria"=> { "0"=> { "include_exclude"=>"1", "display_field_id"=>"survey_responses.created_at", "condition"=>"equals", "value"=>"05/20/2014" } } }
# }
