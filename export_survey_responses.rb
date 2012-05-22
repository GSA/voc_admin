require 'csv'

print "enter survey version id: "
sv_id = gets

sv = SurveyVersion.find(sv_id)


csv_string = CSV.open("responses_export.csv", "wb") do |csv|
  csv << ["Date", "Page URL"].concat(sv.display_fields.map(&:name))

  sv.survey_responses.processed.find_in_batches do |responses|
    responses.each do |response|
      csv << [response.created_at, response.page_url].concat(response.display_field_values.joins(:display_field).order("display_fields.display_order asc").map {|dfv| dfv.value.gsub("{%delim%}", ", ")})
    end
  end
end
