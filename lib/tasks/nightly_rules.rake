namespace :nightly_rules do

  desc "Start nightly rules runner"
  task :start => [:environment] do
    load_config 

    ## Using Kernel.spawn and Process.detach because regular system() call would
    ## cause the processes to quit when capistrano finishes
    options = {
            :pgroup => true,   # create a new process group
            :err => [File.join(@log_path, @log_file), "a"],
            :out => [File.join(@log_path, @log_file), "a"]
          }

    pid = spawn({ "RAILS_ENV" => @rails_env }, "rake nightly_rules:process", options)

    #record pid
    puts "Started worker with name #{@who_am_i} and pid #{pid}"
    pid_file = File.new(@pid_loc, 'w')
    pid_file.puts(pid)
    pid_file.close

    #detach the worker
    Process.detach(pid)
  end

  desc "Stop nightly rules runner"
  task :stop => [:environment] do
    load_config

    begin
      pid_file = File.new(@pid_loc, 'r')
    rescue
      puts "No pid file found - did you start the response parser?"
      exit
    end

    pid_file.readlines.each do |pid|
      puts "Stopping #{pid}"
      begin
        Process.kill("HUP", pid.to_i)
      rescue
        puts "Error while stopping #{pid} - #{$!.to_s}"
      end
    end
    pid_file.close
    File.delete(@pid_loc)
  end

  desc "Run a nightly rules runner without forking (handy for Windows)"
  task :process => [:environment] do
    load_config

    process_nightly
  end

  private

  def load_config
    #get configuration file
    @parser_yml = YAML::load(File.open('config/response_parser.yml'))
    config = @parser_yml.try(:[], "configuration")

    puts "ERROR: Configuration not found! Exiting." && exit unless config

    #Setup params
    @who_am_i = (config.try(:[], "instance_name") || "response_parser") + "_nightly"

    @rails_env = ENV.try(:[], 'RAILS_ENV') ||
                'development'
    
    @nightly_run_hour = config.try(:[], "nightly_run_hour") || 0

    @pid_path = config.try(:[], "pid_path") || 'tmp/pids'
    @pid_loc = File.join(@pid_path,"#{@who_am_i}.pid")

    #set log level 0 = Silent, 1 = Verbose, 2 = Notice, 3 = DB, 4 = Warning, 5 = Error
    @log_level = config.try(:[], "log_level") || 1

    @log_path = config.try(:[], "@log_file_path") || 'log'
    @log_file = "#{@who_am_i}.log"
  end

  #define nightly process
  def process_nightly
    log_event(%Q{
--------------------------------------------------------------------------------
Starting nightly rules processing: #{@who_am_i}

Using:
\tParser config: #{@parser_yml}
with:
\tLog Level: #{log_levels[@log_level]}
\tRails Env: #{@rails_env}
\tMode:      nightly @ #{@nightly_run_hour}
    }, 1)

    log_event("Starting Main Loop")
    #set date of last run to yesterday to force check of system
    date_last_run = Date.today - 1.day

    loop do
      #check time
      if Time.now.hour > @nightly_run_hour.to_i && Date.today > date_last_run
        #set new run times
        date_last_run = Date.today

        log_event("Starting nightly rules processing.")

        update_survey_version_visit_counts

        execute_nightly_rules

        reload_question_reporting_db

        log_event("Nightly rules processing complete.")
      end
      sleep 5
    end
  end

  def update_survey_version_visit_counts
    log_event(" Updating survey version visit counts...", 2)

    #update survey visit count from temporary count
    SurveyVersion.find_each {|sv| sv.update_visit_counts }

    log_event(" Finished updating survey version visit counts.", 2)
  end

  def execute_nightly_rules
    # Pull nightly rules, grouped by Survey Version ID
    grouped_rules = ExecutionTriggerRule.where(execution_trigger_id: 4).includes(:rule).map { |etr| etr.rule }.sort_by { |r| r.rule_order }.group_by { |r| r.survey_version_id }

    grouped_rules.each do |sv_id, rule_group|
      responses = SurveyResponse.where(survey_version_id: sv_id)

      log_event(" Processing #{rule_group.count} rule(s) in survey version #{sv_id} against #{responses.count} responses")

      begin
        responses.find_each do |sr|
          rule_group.each do |rule|
            begin
              rule.apply_me(sr)
              sr.update_attributes(:status_id => Status::DONE, :last_processed => Time.now)
            rescue
              sr.update_attributes(:status_id => Status::ERROR, :last_processed => Time.now)
              puts " Processing failed for rule #{rule.id} - #{$!.to_s}"
            end
          end
        end

        log_event(" Finished processing #{sv_id}")
      rescue
        log_event("Error processing #{sv_id} - #{$!.to_s}", 4)
      end
    end
  end

  def reload_question_reporting_db
    log_event(" Reloading question reporting DB...", 2)
    
    # run task and any dependent tasks
    Rake::Task["reporting:load_questions"].execute

    log_event(" Finished reloading question reporting DB.")
  end

  def log_event(message, level = 2)
    puts "#{Time.now.to_s} - #{log_levels[level]}: " + message if @log_level <= level && @log_level != 0
    $stdout.flush
  end

  def log_levels
    {
      0 => 'Silent',
      1 => 'Verbose',
      2 => 'Notice',
      3 => 'DB',
      4 => 'Warning',
      5 => 'Error'
    }
  end
end
