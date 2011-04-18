#load models and gems
require "rubygems"
require "active_record"
require 'yaml'

#load configuration info
railsenv = (ENV['RAILS_ENV'] != nil && ENV['RAILS_ENV'] != '') ? ENV['RAILS_ENV'] : 'development'
parseryaml = YAML::load(File.open('../config/database.yml'))
dbyaml = YAML::load(File.open('../config/database.yml'))

#create connection to DB and Load models
ActiveRecord::Base.establish_connection(dbyaml[railsenv])
Dir["../app/models/*.rb"].each {|file| require file }

loop do
  RawResponse.transaction do
    
  end
end