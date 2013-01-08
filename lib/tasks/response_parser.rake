require "rubygems"
require "active_record"
require 'yaml'

namespace :response_parser do
  desc "Start response parsers"
  task :start do

    #get configuration file
    parseryaml = YAML::load(File.open('config/response_parser.yml'))

    #Setup params
    who_am_i_base = (parseryaml["configuration"]["instance_name"] if parseryaml["configuration"]) || "response_parser"
    railsenv = (parseryaml["configuration"]["environment"] if parseryaml["configuration"]) || ((ENV['RAILS_ENV'] != nil && ENV['RAILS_ENV'] != '') ? ENV['RAILS_ENV'] : 'development')
    dbyaml_path = (parseryaml["configuration"]["db_yml_path"] if parseryaml["configuration"]) || 'config/database.yml'
    dbyaml = YAML::load(File.open(dbyaml_path))
    nightly_run_hour = (parseryaml["configuration"]["nightly_run_hour"] if parseryaml["configuration"]) || 0
    #set log level 0 = Silent, 1 = Verbose, 2 = Notice, 3 = DB, 4 = Warning, 5 = Error
    @log_level = (parseryaml["configuration"]["log_level"] if parseryaml["configuration"]) || 1
    log_path = (parseryaml["configuration"]["log_file_path"] if parseryaml["configuration"]) || ''
    pid_path = (parseryaml["configuration"]["pid_path"] if parseryaml["configuration"]) || 'tmp/pids'


    #cycle through modes
    ["new", "nightly"].each do |mode|

      #start workers
      parseryaml["configuration"][mode].times do |instance_num|

        who_am_i = who_am_i_base + "_" + mode + "_" + instance_num.to_s

        #start workers
        pid = fork do
          Signal.trap("HUP") { log_event "Exiting...",2; exit }
          log_file = "#{who_am_i}.log"
          $stdout = File.new(File.join(log_path,log_file), 'a')

          if @log_level > 0
            puts "--------------------------------------------------------------------------------"
            puts "Starting Responce parser: #{who_am_i}"
            puts "Using:"
            puts "\t Parser config: #{parseryaml}"
            puts "\t Database YAML @: #{dbyaml_path}"
            puts "with:"
            puts "\tLog Level: #{@log_level}"
            puts "\tRails Env: #{railsenv}"
            if mode == "nightly"
              puts "\tMode:      #{mode} @ #{nightly_run_hour}"
            else
              puts "\tMode:      #{mode}"
            end
            puts ""
          end

          #Load rails
          log_event("Starting Rails",3)
          require File.dirname(__FILE__) + "/../../config/application"
          Rails.application.require_environment!

          #pick a process
          if mode == "new"
            process_new(who_am_i)
          elsif mode == "nightly"
            process_nightly(who_am_i, nightly_run_hour)
          else
            raise "Invalid Mode (#{mode}) specified, try 'new' or 'nightly'"
          end

        end
        #record pid
        puts "Started worker with name #{who_am_i} and pid #{pid}"
        pidfile = File.new(File.join(pid_path,"response_parser.pids"), 'a')
        pidfile.puts(pid)
        pidfile.close

        #detach the worker
        Process.detach(pid)
      end
    end
  end

  desc "Stop Response Parsers"
  task :stop do
    parseryaml = YAML::load(File.open('config/response_parser.yml'))
    pid_path = (parseryaml["configuration"]["pid_path"] if parseryaml["configuration"]) || 'tmp/pids'
    begin
      pidfile = File.new(File.join(pid_path,"response_parser.pids"), 'r')
    rescue
      puts "No pid file found - did you start the response parser?"
      exit
    end
    pidfile.readlines.each do |pid|
      puts "Stopping #{pid}"
      begin
        Process.kill("HUP", pid.to_i)
      rescue
        puts "Error while stopping #{pid} - #{$!.to_s}"
      end
    end
    pidfile.close
    File.delete(File.join(pid_path,"response_parser.pids"))
  end


  private
  def log_event(message, level)
    level_text = ''
    case level
    when 1
      level_text = 'Verbose'
    when 2
      level_text = 'Notice'
    when 3
      level_text = 'DB'
    when 4
      level_text = 'Warning'
    when 5
      level_text = 'Error'
    end
    puts "#{Time.now.to_s} - #{level_text}: " + message if @log_level <= level && @log_level != 0
    $stdout.flush
  end

  #define nightly process
  def process_nightly(who_am_i, nightly_run_hour)
    log_event("Starting Main Loop",2)
    #set date of last run to yesterday to force check of system
    date_last_run = Date.today - 1.day

    loop do
      #check time
      if Time.now.hour > nightly_run_hour.to_i && Date.today > date_last_run
        log_event("Starting Nightly run",2)
        #set new run times
        date_last_run = Date.today

        #start processing
        loop do
          sr = SurveyResponse.get_next_response(who_am_i, "nightly", date_last_run)
          if sr.nil?
            break
          end
          log_event("Processing survey response #{sr.id}",2)
          begin
            sr.process_me(4)
            log_event("Finished processing #{sr.id}",2)
          rescue
            log_event("Error processing #{sr.id} - #{$!.to_s}",4)
          end
        end
      end
      sleep 5
    end
  end

  #define new process
  def process_new(who_am_i)
    log_event("Starting Main Loop",2)
    loop do
      sr = SurveyResponse.get_next_response(who_am_i, "new")
      unless sr
        log_event("No new messages sleeping", 1)
        sleep 5
        next
      end
      log_event("Processing survey response #{sr.id}",2)
      begin
        sr.process_me(1)
        log_event("Finished processing #{sr.id}",2)
      rescue
        log_event("Error processing #{sr.id} - #{$!.to_s}",4)
      end
    end
  end
end