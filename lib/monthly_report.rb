class MonthlyReport
  TIME_ZONE_STR = "Eastern Time (US & Canada)".freeze

  def initialize month, year
    @month = month
    @year = year
  end

  def generate
    CSV.open(Rails.root + file_name,"wb") do |csv|
      add_monthly_total_for_all_versions(csv)
      add_yearly_total_for_all_versions(csv)
      add_total_responses_for_all_versions(csv)
      add_column_headers(csv)

      SurveyVersion.includes(:survey)
        .where(surveys: { archived: false }, survey_versions: { archived: false })
        .order("surveys.id asc, survey_versions.major asc, survey_versions.minor asc")
        .each do |sv|
        csv << [sv.survey_id,
          sv.survey_name,
          "v#{sv.version_number}",
          version_response_counts_for_month.fetch(sv.id, 0),
          version_response_counts_for_year.fetch(sv.id, 0),
          version_response_counts.fetch(sv.id, 0)
        ]
      end
    end
  end

  private

  def add_column_headers csv
    csv << ["Survey ID", "Survey", "Survey Version",
      "Monthly - Number of Responses", "Year - Number of Responses",
      "Total - Number of Responses"]
  end

  def add_monthly_total_for_all_versions csv
    csv << ["Monthly Total",
      total_responses_for_month,
      "Time Period",
      beginning_of_month.strftime(" Start: %m/%d/%Y"),
      end_of_month.strftime("End: %m/%d/%Y")
    ]
  end

  def add_yearly_total_for_all_versions csv
    csv << ["Year Total",
      total_responses_for_year,
      "Time Period",
      beginning_of_month.strftime(" Start: 1/1/%Y"),
      end_of_month.strftime("End: %m/%d/%Y")
    ]
  end

  def add_total_responses_for_all_versions csv
    csv << ["All Time Total",
      total_responses,
      "Time Period",
      SurveyResponse.first.created_at.strftime(" Start: %m/%d/%Y"),
      end_of_month.strftime("End: %m/%d/%Y")
    ]
  end

  def file_name
    "#{@month}_#{@year}_report.csv"
  end

  def total_responses_for_month
    @total_responses_for_month ||= version_response_counts_for_month
      .inject(0) { |sum, (k,v)| sum + v }
  end

  def total_responses_for_year
    @total_resonses_for_year ||= version_response_counts_for_year
      .inject(0) { |sum, (k,v)| sum + v }
  end

  def total_responses
    @total_responses ||= version_response_counts
      .inject(0) { |sum, (k,v)| sum + v }
  end

  def version_response_counts_for_month
    @version_response_counts_for_month ||= SurveyResponse
      .includes(survey_version: :survey)
      .where(survey_versions: { archived: false }, surveys: { archived: false })
      .where(survey_responses: { created_at: beginning_of_month..end_of_month })
      .group(:survey_version_id)
      .count
  end

  def version_response_counts_for_year
    @version_response_counts_for_year ||= SurveyResponse
      .includes(survey_version: :survey)
      .where(survey_versions: { archived: false }, surveys: { archived: false })
      .where(survey_responses: { created_at: beginning_of_year..end_of_month })
      .group(:survey_version_id)
      .count
  end

  def version_response_counts
    @version_response_counts ||= SurveyResponse
      .includes(survey_version: :survey)
      .where(survey_versions: { archived: false }, surveys: { archived: false })
      .where("survey_responses.created_at <= ?", end_of_month)
      .group(:survey_version_id)
      .count
  end

  def beginning_of_month
    @beginning_of_month ||= parse_date_string_in_time_zone(date_str)
  end

  def end_of_month
    @end_of_month ||= beginning_of_month.end_of_month
  end

  def beginning_of_year
    @beginning_of_year ||= beginning_of_month.beginning_of_year
  end

  def date_str
    "#{@year.to_i}-#{@month.to_i}-1"
  end

  def parse_date_string_in_time_zone date_string, zone = TIME_ZONE_STR
    ActiveSupport::TimeZone[zone].parse(date_string)
  end

end
