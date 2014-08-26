namespace :remove_scan do
  desc "Remove security scan entries from db"
  task :delete_survey_responses => [:environment] do
    puts "Starting at #{Time.now}"
    #Your start date and end dates need to allign correctly.
    start_date = ['2014-05-02','2014-06-02','2014-06-30', '2014-07-10', '2014-07-20']
    end_date = ['2014-05-06','2014-06-03','2014-07-06', '2014-07-12', '2014-07-23']
    @scancnt = 0
    start_date.each do |dates|
      @record_list = SurveyResponse.order("id").where("created_at > ? and created_at < ?", start_date[@scancnt].to_date, end_date[@scancnt].to_date + 1)

      @recordcnt = 1
      @record_list.each do |response|
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
              s.created_at =  response.created_at
              s.updated_at =  response.updated_at
              s.status_id =  response.status_id
              s.last_processed =  response.last_processed
              s.worker_name =  response.worker_name
              s.page_url =  response.page_url
              s.archived =  response.archived
              s.device =  response.device
              s.save

            @raw_resp = RawResponse.where(:survey_response_id => response.id)
            @raw_resp.each do |raw|
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
              puts "Response id is #{response.id}"
              @represponse = ReportableSurveyResponse.where(:survey_response_id => response.id).first
              unless @represponse.nil?
                @represponse.remove
              end
            end
          end
        @recordcnt += 1
       end
      @scancnt += 1
    end
    puts "Ending at #{Time.now}"
    puts "Total records removed is #{@recordcnt}"
  end
end