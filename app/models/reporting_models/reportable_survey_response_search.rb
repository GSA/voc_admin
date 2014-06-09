class ReportableSurveyResponseSearch
  attr_accessor :criteria, :conditions, :parameters, :clause_joins

  CONDITIONS = {
    'equals' => proc {|base_scope, field_name, value| base_scope.where(field_name => value) },
    'contains' => proc {|base_scope, field_name, value| base_scope.where(field_name => Regex.new("/#{value}/").to_s) },
    'begins_with' => proc {|base_scope, field_name, value| base_scope.where(field_name => Regex.new("/^#{value}/").to_s) },
    'ends_with' => proc {|base_scope, field_name, value| base_scope.where(field_name => Regex.new("/#{value}$/").to_s) },
    'less_than' => proc {|base_scope, field_name, vale| base_scope.where( "#{field_name}.lt" => value) },
    'greater_than' => proc {|base_scope, field_name, value| base_scope.where( "#{field_name}.gt" => value) }
  }

  def initialize(attribs = nil)
    @criteria = attribs['criteria'] #((attribs && attribs['criteria']) || {}).delete_if {|key, value| value['value'].blank? }
    @conditions = []
    @parameters = []
    @clause_joins = []
    puts attribs
  end

  def search(base_scope = nil)
    base_scope ||= ReportableSurveyResponse

    criteria.each do |k, criterion|
      if %w( survey_responses.page_url survey_responses.device ).include?(criterion['display_field_id'])
        search_field = criterion['display_field_id'].split('.').last
        condition = criterion['condition']
        base_scope = CONDITIONS[condition].call(base_scope, search_field, criterion['value'])
      elsif criterion['display_field_id'] == 'survey_responses.created_at'
        # value is a date field
      else
        search_field = criterion['display_field_id']
        condition = criterion['condition']
        base_scope = CONDITIONS[condition].call(base_scope, "answers.#{search_field}", criterion['value'])
      end
    end
    base_scope
  end
end

# {
  # "search"=> {
  # { "criteria"=> { "0"=> { "include_exclude"=>"1", "display_field_id"=>"survey_responses.created_at", "condition"=>"equals", "value"=>"05/20/2014" } } }
# }
