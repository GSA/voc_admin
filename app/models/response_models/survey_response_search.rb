class SurveyResponseSearch
  attr_accessor :criteria, :conditions, :parameters

  SQLConditions = {
    'equals' => '=',
    'contains' => 'LIKE',
    'begins_with' => 'LIKE',
    'ends_with' => 'LIKE',
    'less_than' => '<',
    'greater_than' => '>'
  }

  NegationSQL = {
    'equals' => '!=',
    'contains' => 'NOT LIKE',
    'begins_with' => 'NOT LIKE',
    'ends_with' => 'NOT LIKE',
    'less_than' => '>=',
    'greater_than' => '<='
  }

  def initialize(attribs = nil)
    @criteria = ((attribs && attribs['criteria']) || {}).delete_if {|key, value| value['value'].blank? }
    @conditions = []
    @parameters = []
    @clause_joins = []

    # clean_criteria

    build_condition_string

  end

  # Apply the built where clause to the passed Relation
  def search(passed_scope)
    passed_scope.where("#{condition_string}", *parameters)
  end

  # condition_string: return the full condition and parameters string to be passed
  # to the where clause.
  #
  # "(display_field_values.display_field_id = ? AND display_field_values.value #{condition}) AND/OR
  # (display_field_values.display_field_id = ? AND display_field_values.value #{condition}) AND/OR
  # (display_field_values.display_field_id = ? AND display_field_values.value #{condition})"
  def condition_string
    result = ""

    @conditions.each_with_index do |con, index|
      result << con if index == 0
      result << " #{@clause_joins[index-1]} #{con}" if index > 0
    end

    result
  end

  # Array of parameters to the condition string
  def parameters
    @parameters
  end


  private
  def build_condition_string
    @criteria.each do |k, criteria_fields|
      next if criteria_fields['value'].blank?  # If there is no value to compare against don't add to the where clause

      # "(display_field_values.display_field_id = ? AND display_field_values.value #{condition})"
      condition_sql = ""
      condition_params = []

      if %w(survey_responses.page_url survey_responses.created_at).include?(criteria_fields['display_field_id'])

        # The display_field_id is actually the full column name we want to use in the where clause
        operator = sql_condition(criteria_fields['include_exclude'], criteria_fields['condition'])
        condition_sql = "#{criteria_fields['display_field_id']} #{operator} ?"

        if criteria_fields['display_field_id'] == 'survey_responses.created_at'
          # When the display_field_id == 'survey_responses.created_at' then we need to convert the value to a datetime object
          begin
            # chomp the value
            criteria_fields['value'].chomp!

            # Set the time format string based on the datetime input by the  user
            if /\d{1,2}\/\d{1,2}\/\d{4}\s\d{2}:\d{2}:\d{2}/.match(criteria_fields['value'])
              time_string = "%m/%d/%Y %H:%M:%S"
            elsif /\d{1,2}\/\d{1,2}\/\d{4}\s\d{2}:\d{2}/.match(criteria_fields['value'])
              time_string = "%m/%d/%Y %H:%M"
            elsif /\d{1,2}\/\d{1,2}\/\d{4}/.match(criteria_fields['value'])
              time_string = '%m/%d/%Y'
            else
              next # The time submitted date does not fit any of the formats so skip the condition
            end

            search_time = Time.strptime(criteria_fields['value'] + " #{Time.zone.now.formatted_offset}", time_string.chomp + " %:z")
            search_time += 1.day if time_string == "%m/%d/%Y" && operator == ">"
            search_time = search_time + 1.day - 1.second if time_string == "%m/%d/%Y" && operator == "<="


            condition_params << search_time

          rescue
            next # An error was raised when processing Time.strptime() meaning we have an invalid date
          end
        else
          # When the display_field_id == 'survey_resposnes.page_url' just add the condition directly on
          condition_params << value_bind(criteria_fields['value'], criteria_fields['condition'])
        end




      else
        # Add the field to search
        field_to_search = "display_field_values.display_field_id = ?"
        condition_params << criteria_fields['display_field_id']

        # add the condition check
        condition = "display_field_values.value #{sql_condition(criteria_fields['include_exclude'], criteria_fields['condition'])} ?"

        # add the condition parameter
        condition_params << value_bind(criteria_fields['value'], criteria_fields['condition'])

        condition_sql = "(#{field_to_search} AND #{condition})"
      end

      @conditions << condition_sql
      @parameters.concat(condition_params)

      @clause_joins << (criteria_fields['clause_join'] || 'AND') unless @conditions.size == 1
    end
  end

  def sql_condition(negation, condition)
    negation == '0' ? NegationSQL[condition] : SQLConditions[condition]
  end

  def value_bind(val, condition)
    case condition
    when 'contains'
      "%#{val}%"
    when 'begins_with'
      "#{val}%"
    when 'ends_with'
      "%#{val}"
    else
      val
    end
  end
end