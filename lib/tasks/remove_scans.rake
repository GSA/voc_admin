namespace :remove_scan do
  desc "Remove security entries. Expects parameters Start Date and End date in format YYYY-MM-DD"

  task :delete_survey_responses, [:start, :end] => [:environment] do |t, args|
    puts "Starting at #{Time.now}" 
     start_date = args[:start]
     end_date = args[:end]
      @record_list = SurveyResponse.order("id").where("created_at > ? and created_at < ?", start_date, end_date)
      @recordcnt = 1

      survey_version_arr = Array.new

      @record_list.find_each do |response|
          if @recordcnt == 1
            @prev_record_date = response.created_at
            @current_record_date = response.created_at
          else
            @prev_record_date = @current_record_date
            @current_record_date = response.created_at
          end

          if  response.page_url.nil? or
              response.page_url.include?("passwd") or
              response.page_url.include?("88952634") or
              response.page_url == "undefined/surveys/111" or
              response.page_url == "" or
              response.page_url == "undefined/surveys/1" or
              response.page_url == "undefined/surveys/11" or response.page_url == "undefined/surveys/31" or 
              response.page_url == "undefined/surveys/91" or response.page_url.include?("set&set") or
              response.page_url =~ /undefined\/surveys\/./ or
              response.page_url.include?("/../") or response.page_url.include?("5=5") or 
              response.page_url == "undefined/surveys/41" or
              response.page_url == "|" or
              response.page_url == "+" or
              response.page_url.include?("etc/passwd") or
              response.page_url.include?("etc/\passwd") or
              response.page_url.include?("<SCRIPT>alert") or
              response.page_url.include?("Andiparos") or
              response.page_url.include?(" AND ") or
              response.page_url.include?("waitfor delay") or
              response.page_url.include?("Set-cookie:") or
              response.page_url.include?("${\"PRexfxa") or
              response.page_url.include?("www.webinspect.hp.com") or
              response.page_url.include?("15.216.12.12/serverinclude") or
              response.page_url.include?("sPiDoM") or
              response.page_url.include?("does.not.exist.spidynamics.com") or
              response.page_url.include?("!@$^*") or
              response.page_url == "%00" or
              response.page_url == "%0a" or
              response.page_url.include?("{}") or
              response.page_url == "^'" or
              response.page_url == "." or
              response.page_url == "*" or
              response.page_url == "/" or
              response.page_url == "'" or
              response.page_url == "/,%ENV,/" or
              response.page_url == "@'" or
              response.page_url == "`" or
              response.page_url == "\u0000" or
              response.page_url.starts_with?("set") or
              response.page_url.ends_with?("A:B")
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

            if !survey_version_arr.include?(response.survey_version_id)
              survey_version_arr << response.survey_version_id
            end  
            @recordcnt += 1
          end
       end

    #reload questions here
    survey_version_arr.each do |sv| 
      svr = SurveyVersionReporter.where(:sv_id => sv).first
      puts "deleting svreporter for survey version id.... " + sv.to_s
      svr.destroy
      puts "recreate svreporter for survey version id.... " + sv.to_s
      SurveyVersionReporter.find_or_create_reporter(sv).update_reporter!
    end   
    puts "Total records removed is #{@recordcnt}"
  end
end