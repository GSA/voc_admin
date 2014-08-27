namespace :remove_scan do
  desc "Remove security entries. Expects parameters Start Date and End date in format YYYY-MM-DD"

  task :delete_survey_responses, [:start, :end] => [:environment] do |t, args|
    puts "Starting at #{Time.now}" 
     start_date = args[:start]
     end_date = args[:end]
      @record_list = SurveyResponse.order("id").where("created_at > ? and created_at < ?", start_date, end_date)
      @recordcnt = 1
      @record_list.find_each do |response|
          if @recordcnt == 1
            @prev_record_date = response.created_at
            @current_record_date = response.created_at
          else
            @prev_record_date = @current_record_date
            @current_record_date = response.created_at
          end

          if ((@current_record_date - @prev_record_date).round >= 0 and 
              (@current_record_date - @prev_record_date ).round < 2) or
              response.page_url.nil? or
              response.page_url.include?("passwd") or
              response.page_url == "undefined/surveys/111" or
              response.page_url == "undefined/surveys/1" or
              response.page_url == "undefined/surveys/11" or response.page_url == "undefined/surveys/31" or 
              response.page_url == "undefined/surveys/91" or response.page_url.include?("set&set") or 
              response.page_url.include?("/../") or response.page_url.include?("5=5") or response.page_url == "undefined/surveys/41" 
            s = ScanDelete.new
              s.survey_response_id = response.id
              s.client_id =  response.client_id
              s.survey_version_id = response.survey_version_id
              s.orig_created_at =  response.created_at
              s.orig_updated_at =  response.updated_at
              s.status_id =  response.status_id
              s.last_processed =  response.last_processed
              s.worker_name =  response.worker_name
              s.page_url =  response.page_url
              s.archived =  response.archived
              s.device =  response.device
              s.save

            @raw_resp = RawResponse.where(:survey_response_id => response.id)
            @raw_resp.find_each do |raw|
              r = ScanRawResponse.new
              r.raw_response_id = raw.id
              r.client_id = raw.client_id
              r.answer = raw.answer
              r.question_content_id = raw.question_content_id
              r.status_id = raw.status_id
              r.worker_name = raw.worker_name
              r.survey_response_id = raw.survey_response_id
              r.save
            end
            if SurveyResponse.destroy(response.id)
              RawResponse.where(:survey_response_id => response.id).destroy_all
              @represponse = ReportableSurveyResponse.where(:survey_response_id => response.id).first
              unless @represponse.nil?
                @represponse.remove
              end
            end
          end
        @recordcnt += 1
       end
    puts "Total records removed is #{@recordcnt}"
  end
end