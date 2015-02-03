class ExportResponsesToCsv
  attr_accessor :filter_params, :user_id, :survey_version, :export

  DEFAULT_BATCH_SIZE = 1000

  def initialize(survey_version, filter_params, user_id)
    @survey_version = survey_version
    @filter_params = filter_params
    @user_id = user_id
  end

  def survey_response_query
    @survey_response_query ||= begin
      search_params = filter_params.fetch('search', nil) || filter_params.fetch('simple_search', nil)
      ElasticsearchQuery.new(survey_version.id, search_params)
    end
  end

  def survey_responses_in_batches(batch_size = DEFAULT_BATCH_SIZE, &block)
    return survey_response_query.reportable_survey_responses_in_batches unless block_given?
    survey_response_query.reportable_survey_responses_in_batches(&block)
  end

  def export_csv
    # Write the survey responses to a temporary CSV file which will be used to create the
    # Export instance.  The document will be copied to the correct location by paperclip
    # when the Export instance is created.
    CSV.open("#{Rails.root}/tmp/#{file_name}", "wb") do |csv|
      csv << ["Date", "Page URL"].concat(ordered_columns.map(&:name))

      survey_responses_in_batches do |batch|
        puts "Exporting batch to CSV"
        batch.each do |response|
          # Write the completed row to the CSV
          csv << [response.created_at, response.page_url].concat(response_record(response))
        end
      end
    end

    create_export
    send_export_file

    # Remove the temporary file used to create this export
    File.delete("#{Rails.root}/tmp/#{file_name}")
  end

  def response_record(response)
    # For each column we're looking to export...
    ordered_columns.map do |df|
      # Ask for the answer keyed on DisplayField id, fall back on default
      response.answers[df.id.to_s].presence || df.default_value.to_s

      # Pass the entire array through a filter to break up multiple selection answers when done
    end.map! {|rr| rr.gsub("{%delim%}", ", ")}
  end

  def file_name
    @file_name ||= "#{Time.now.strftime("%Y%m%d%H%M")}-#{survey_name}-#{version_number}.csv"
  end

  def version_number
    @version_number ||= survey_version.version_number
  end

  def survey_name
    survey_version.survey.name[0..10]
  end

  def create_export
    @export = survey_version.exports.create! :document => File.open("#{Rails.root}/tmp/#{file_name}")
  end

  def send_export_file
    # Notify the user that the export has been successful and is available for download
    if export.persisted?
      resque_args = User.find(user_id).email, export.id

      begin
        Resque.enqueue(ExportMailer, *resque_args)
      rescue
        ResquedJob.create(class_name: "ExportMailer", job_arguments: resque_args)
      end
    end
  end

  def custom_view
    @custom_view ||= if filter_params['custom_view_id'].blank?
      survey_version.custom_views.find_by_default(true)
    else
      # Use find_by_id in order to return nil if a custom view with the specified id
      # cannot be found instead of raising an error.
      survey_version.custom_views.find_by_id(filter_params['custom_view_id'])
    end
  end

  def custom_view?
    custom_view.present?
  end

  def ordered_columns
    @ordered_columns ||= if custom_view?
      custom_view.ordered_display_fields
    else
      survey_version.display_fields.order(:display_order)
    end
  end
end
