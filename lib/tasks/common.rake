desc "drop, create, migrate and seed the DB"
task :recreate_dev =>['db:drop', 'db:create', 'db:migrate', 'db:seed', 'add_test_data', 'db:test:prepare' ]

namespace :application do
  desc "start the application and all required background jobs and processes"
  task :start_all => [:environment, "memcache:start", "unicorn:start", "resque:start_workers"] do
  end

  desc "stop the application and all background jobs and processes"
  task :stop_all => :environment do
    ["memcache:stop", "unicorn:stop", "resque:stop_workers"].each do |t|
      begin
        Rake::Task[t].execute
      rescue
        puts "#{t} unable to be stopped - #{$!.to_s}"
      end
    end
  end

  desc "restart the application and all background jobs and processes"
  task :restart_all => [:stop_all, :start_all]

  desc "(JRuby) start all required background jobs and processes"
  task :start_jruby => [:environment, "resque:start_workers"] do
  end
end
