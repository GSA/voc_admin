
desc "Push all survey responses to NOSQL"
task :export_reporting => [:environment] do

  puts "Starting export for #{SurveyResponse.count} records..."

  SurveyResponse.all.each do |sr|
    puts "  Exporting ID# #{sr.id}..."

    begin
      sr.export_for_reporting

      puts "  ...exported."
    rescue
      puts "  ...failed with error: #{$!.to_s}"
    end
  end

  puts "...export finished."
end
