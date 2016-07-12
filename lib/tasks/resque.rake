# loads all rake task of resque
require 'resque/tasks'

# # following statement is required only if your background task needs rails enviroment else skip it
# task "resque:setup" => :environment

# Start a worker with proper env vars and output redirection
def run_workers
  env_vars = ENV.to_hash.slice("RAILS_ENV", "PIDFILE")

  ops = {:pgroup => true, :err => [File.join(Rails.root, "log/resque_err.log"), "a"],
                          :out => [File.join(Rails.root + "log/resque_stdout.log"), "a"]}
  env_vars['COUNT'] = ENV['NUM_WORKERS']
  env_vars['QUEUE'] = "voc_rules,voc_responses,voc_report_email,voc_dfs"
  run_worker(env_vars, ops)
  env_vars['COUNT'] = ENV['NUM_EXPORT_WORKERS']
  env_vars['QUEUE'] = "voc_csv"
  run_worker(env_vars, ops)
end

def run_worker(env_vars, ops)
  puts "Starting #{env_vars['COUNT']} worker(s) with QUEUE: #{env_vars['QUEUE']}"
  ## Using Kernel.spawn and Process.detach because regular system() call would
  ## cause the processes to quit when capistrano finishes
  pid = spawn(env_vars, "rake resque:workers", ops)
  pidfile = File.open(File.join(Rails.root+"tmp/pids/resque.pid"),"a")
  pidfile.write(" #{pid}")
  puts "Work pid:#{pid} written to file #{File.join(Rails.root+"tmp/pids/resque.pid")}"
  Process.detach(pid)
end

namespace :resque do
  task :setup => :environment do
    Resque.before_fork = Proc.new {
      ActiveRecord::Base.establish_connection

      Resque.logger = Logger.new($stdout)
      Resque.logger.level = Logger::INFO
    }
  end

  # desc "Restart running workers"
  # task :restart_workers => :environment do
  #   Rake::Task['resque:stop_workers'].invoke
  #   Rake::Task['resque:start_workers'].invoke
  # end

  desc "Quit running workers"
  task :stop_workers => :environment do
    pids = Resque.workers.first.try(:worker_pids)
    if pids.blank?
      puts "No Resque workers to kill"
    else
      syscmd = "kill -s QUIT #{pids.join(' ')}"
      puts "Stopping Resque with: #{syscmd}"
      File.delete(File.join(Rails.root+"tmp/pids/resque.pid")) if File.exists? File.join(Rails.root+"tmp/pids/resque.pid")
      system(syscmd)
    end
  end

  desc 'Start workers - takes optional ENV vars NUM_WORKERS and NUM_EXPORT_WORKERS'
  task :start_workers => :environment do
    ENV['NUM_WORKERS'] ||= '1'
    ENV['NUM_EXPORT_WORKERS'] ||= '1'
    run_workers
  end
end
