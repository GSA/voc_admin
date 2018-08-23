# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Facilitate searching SurveyResponses using simple boolean conditions.
class SurveyResponseSearch
  attr_accessor :criteria, :conditions, :parameters

  # Used when "include_exclude" is true/include
  SQLConditions = {
    'equals' => '=',
    'contains' => 'LIKE',
    'begins_with' => 'LIKE',
    'ends_with' => 'LIKE',
    'less_than' => '<',
    'greater_than' => '>'
  }

  # Used when "include_exclude" is false/exclude
  NegationSQL = {
    'equals' => '!=',
    'contains' => 'NOT LIKE',
    'begins_with' => 'NOT LIKE',
    'ends_with' => 'NOT LIKE',
    'less_than' => '>=',
    'greater_than' => '<='
  }

  # Removes empty values on the passed in criteria before building the SQL condition string.
  #
  # ==== Example
  #
  # !{"criteria"=>{"0"=>{"include_exclude"=>"1", "display_field_id"=>"39", "condition"=>"equals", "value"=>"b"}, "1354716800350"=>!{"clause_join"=>"OR", "include_exclude"=>"0", "display_field_id"=>"42", "condition"=>"contains", "value"=>"testval"}}}
  #
  # @param [Hash] attribs the search parameters
  def initialize(attribs = nil)
    @criteria = ((attribs && attribs['criteria']) || {}).delete_if {|key, value| value['value'].blank? }
    @conditions = []
    @parameters = []
    @clause_joins = []

    build_condition_string
  end

  # Apply the built WHERE clause to the passed Relation.
  #
  # @param [ActiveRecord::Relation] passed_scope the Relation representing the SurveyResponse query to filter
  # @return [ActiveRecord::Relation] the modified Relation
  def search(passed_scope)
    passed_scope.where("#{condition_string}", *parameters)
  end

  # Creates the full condition and parameters string to be passed to the WHERE clause in :search
  #
  # ==== Example
  #
  # "(display_field_values.display_field_id = ? AND display_field_values.value #!{condition}) AND/OR
  # (display_field_values.display_field_id = ? AND display_field_values.value #!{condition}) AND/OR
  # (display_field_values.display_field_id = ? AND display_field_values.value #!{condition})"
  #
  # @return [String] the full SQL WHERE clause for filtering the SurveyResponse Relation
  def condition_string
    conditionals = ""

    @conditions.each_with_index do |con, index|
      conditionals << con if index == 0
      conditionals << " #{@clause_joins[index-1]} #{con}" unless index == 0
    end

    conditionals
  end

  # Array of parameters to the condition string.
  #
  # ==== Example
  #
  # ["39", "b", "42", "%t%"]
  #
  # @return [Array] DisplayField ids and search values
  def parameters
    @parameters
  end

  private

  # parse out the criteria parameters and build each condition
  def build_condition_string
    @criteria.each do |k, criteria_fields|
      next if criteria_fields['value'].blank?  # If there is no value to compare against don't add to the where clause

      # "(display_field_values.display_field_id = ? AND display_field_values.value #{condition})"
      condition_sql = ""
      condition_params = []

      if %w(survey_response_id survey_responses.page_url survey_responses.created_at survey_responses.device).include?(criteria_fields['display_field_id'])

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

  # choose whether to use inclusive or exclusive SQL logic
  def sql_condition(negation, condition)
    negation == '0' ? NegationSQL[condition] : SQLConditions[condition]
  end

  # apply percent wildcards to accomplish text pattern matching
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
