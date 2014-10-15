namespace :reporting do
  desc "Generate CSV report of published surveys"
  task :published_surveys => [:environment] do
    CSV.open("published_surveys.csv", "wb") do |csv|
      surveys = SurveyVersion.where(published: true).includes(:survey)
      csv << ["Survey Name", "Version Number", "OMB Expiration Date"]
      surveys.map do |sv|
        expiration_date = nil
        sv.assets.any? do |asset|
          if asset.snippet =~ /OMB#.*(\d{2}\/\d{2}\/\d{4})/
            expiration_date = $1
          end
        end
        [sv.survey.name, sv.version_number, expiration_date]
      end.each do |sv|
        csv << sv
      end
    end
  end
end
