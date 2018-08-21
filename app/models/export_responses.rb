require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'

class ExportResponses
  attr_accessor :filter_params, :user_id, :survey_version, :export_file

  DEFAULT_BATCH_SIZE = 1000

  def initialize(survey_version, filter_params, user_id, file_format)
    @survey_version = survey_version
    @filter_params = filter_params
    @user_id = user_id
    @file_format = file_format
  end

  def survey_response_query
    @survey_response_query ||= ElasticsearchQuery.new(survey_version.id, search_params)
  end

  def survey_responses_in_batches(batch_size = DEFAULT_BATCH_SIZE, &block)
    return survey_response_query.reportable_survey_responses_in_batches(batch_size) unless block_given?
    survey_response_query.reportable_survey_responses_in_batches(batch_size, &block)
  end

  def export
    # Write the survey responses to a temporary CSV/XLS file which will be used to create the
    # Export instance.  The document will be copied to the correct location by paperclip
    # when the Export instance is created.
    method("write_#{@file_format}").call

    create_export
    send_export_file

    # Remove the temporary file used to create this export
    File.delete(absolute_file_name)
  end

  def write_csv
    # Write the survey responses to a temporary CSV file which will be used to create the
    # Export instance.  The document will be copied to the correct location by paperclip
    # when the Export instance is created.
    CSV.open(absolute_file_name, "wb") do |csv|
      csv << formatted_header_array

      survey_responses_in_batches do |batch|
        batch.each do |response|
          # Write the completed row to the CSV
          csv << formatted_response_array(response)
        end
      end
    end
  end

  def write_xls
    date_format = Spreadsheet::Format.new(number_format: 'mm/d/yy h:mm')

    Spreadsheet::Workbook.new.tap do |book|
      book.create_worksheet.tap do |sheet|
        begin
          sheet.column(1).default_format = date_format
        rescue
        end

        sheet.row(0).concat formatted_header_array

        row = 1

        survey_responses_in_batches do |batch|
          batch.each do |response|
            # Write the completed row to the CSV
            sheet.row(row).concat formatted_response_array(response)
            sheet.row(row).set_format(1, date_format)

            row += 1
          end
        end

      end

      book.write absolute_file_name
    end
  end

  def search_params
    filter_params.fetch('search', nil) || filter_params.fetch('simple_search', nil)
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

  def absolute_file_name
    @absolute_file_name ||= "#{Rails.root}/tmp/#{file_name}"
  end

  def file_name
    @file_name ||= "#{Time.now.strftime("%Y%m%d%H%M")}-#{survey_name}-#{version_number}.#{@file_format}"
  end

  def version_number
    @version_number ||= survey_version.version_number
  end

  def survey_name
    @survey_name ||= survey_version.survey.name[0..10]
  end

  def formatted_header_array
    ["Survey Response ID", "Date", "Page URL", "Device"].concat(ordered_columns.map(&:name))
  end

  def ordered_columns
    @ordered_columns ||= if custom_view?
      custom_view.ordered_display_fields
    else
      survey_version.display_fields.order(:display_order)
    end
  end

  def formatted_response_array(response)
    [
      response.try(:survey_response_id),
      response.created_at.in_time_zone("Eastern Time (US & Canada)"),
      response.page_url,
      response.device
    ].concat(response_record(response))
  end

  def response_record(response)
    # For each column we're looking to export...
    ordered_columns.map do |df|
      # Ask for the answer keyed on DisplayField id, fall back on default
      response.answers[df.id.to_s].presence || df.default_value.to_s

      # Pass the entire array through a filter to break up multiple selection answers when done
    end.map! {|rr| rr.gsub("{%delim%}", ", ")}
  end

  def create_export
    @export_file = survey_version.exports.create! :document => File.open(absolute_file_name)
  end

  def send_export_file
    # Notify the user that the export has been successful and is available for download
    if export_file.persisted?
      resque_args = User.find(user_id).email, export_file.id, @file_format

      begin
        Resque.enqueue(ExportMailer, *resque_args)
      rescue
        ResquedJob.create(class_name: "ExportMailer", job_arguments: resque_args)
      end
    end
  end
end
