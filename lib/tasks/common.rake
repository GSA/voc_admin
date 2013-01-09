desc "drop, create, migrate and seed the DB"
task :recreate_dev =>['db:drop', 'db:create', 'db:migrate', 'db:seed', 'add_test_data', 'db:test:prepare' ]

namespace :application do
  desc "start the application and all required background jobs and processes"
  task :start_all => [:environment, "memcache:start", "unicorn:start"] do
    puts "starting delayed jobs workers with #{Rails.env} environment"
    sh "#{Rails.root}/script/delayed_job start -n 5"
    sh "rake response_parser:start"
  end

  desc "stop the application and all background jobs and processes"
  task :stop_all => [:environment, "memcache:stop", "unicorn:stop"] do
    puts "stopping delayed jobs workers"
    sh "#{Rails.root}/script/delayed_job stop"
    sh "rake response_parser:stop"
  end

  desc "restart the application and all background jobs and processes"
  task :restart_all => [:stop_all, :start_all]

  desc "(JRuby) start all required background jobs and processes"
  task :start_jruby => :environment do
    sh "rake jobs:work"
    sh "rake response_parser:start"
  end
end