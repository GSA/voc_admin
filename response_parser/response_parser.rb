#load models and gems
require "rubygems"
require "active_record"
require 'yaml'


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
end

#Process Command Line Args
arg_hash = {}
ARGV.each do|a|
  if a.include? "=" 
    parts = a.split "="
    arg_hash[parts[0]] = parts[1]
  end
end

#Load everything & setup
who_am_i = arg_hash["-instance_name"] || "response_parser"
parseryaml = YAML::load(File.open(arg_hash["-config_yml_path"] || '../config/parser.yml'))
railsenv = arg_hash["-rails_env"] || 
           (parseryaml["configuration"]["environment"] if parseryaml["configuration"]) || 
           ((ENV['RAILS_ENV'] != nil && ENV['RAILS_ENV'] != '') ? ENV['RAILS_ENV'] : 'development')
dbyaml_path = arg_hash["-db_yml_path"] || 
              (parseryaml["configuration"]["db_yml_path"] if parseryaml["configuration"]) || 
              '../config/database.yml'
dbyaml = YAML::load(File.open(dbyaml_path))

#set log level
# 0 = Silent
# 1 = Verbose
# 2 = Notice
# 3 = DB
# 4 = Warning
# 5 = Error
@log_level = (arg_hash["-log_level"].to_i if arg_hash["-log_level"]) ||
            (parseryaml["configuration"]["log_level"] if parseryaml["configuration"]) || 1
              
trigger_string = arg_hash["-triggers"] || parseryaml["configuration"]["triggers"] || ""
trigger_id = trigger_string.split(",") if arg_hash["-triggers"]
  
#set mode (new, nightly) 
mode = arg_hash["-mode"] || parseryaml["configuration"]["triggers"] || "new"
               
#check for redirect to file and redirect outpuf if needed
if (arg_hash["-redirect_out"] == "true") || ((parseryaml["configuration"]["redirect_out"] == true ) if parseryaml["configuration"])
  log_path = arg_hash["-log_file_path"] || (parseryaml["configuration"]["log_file_path"] if parseryaml["configuration"]) || ''
  log_file = "#{who_am_i}.log"
  $stdout = File.new(File.join(log_path,log_file), 'a')
end

if @log_level > 0
  puts "--------------------------------------------------------------------------------"
  puts "Starting Responce parser: #{who_am_i}"
  puts "Using:"
  puts "\t Parser config: #{parseryaml}"
  puts "\t Database YAML @: #{dbyaml_path}"
  puts "with:"
  puts "\tLog Level: #{@log_level}"
  puts "\tRails Env: #{railsenv}"
  puts "\tTrigers:   #{trigger_string  == "" ? "All" : trigger_string}"
  puts ""
end
  
#create connection to DB and Load models
log_event("Starting Rails",3)
require File.dirname(__FILE__) + "/../config/application"
Rails.application.require_environment!
  
def process_nightly(who_am_i)
  
end
  
def process_new(who_am_i)
  loop do
    sr = SurveyResponse.get_next_response(who_am_i, "new")
    unless sr
      sleep 5
      next
    end
    sr.process_me(1)
  end
end

if mode == "new"
  process_new(who_am_i)
elsif mode == "nightly"
  process_nightly(who_am_i)
else
  raise "Invalid Mode (#{mode}) specified, try 'new' or 'nightly'"
end



















