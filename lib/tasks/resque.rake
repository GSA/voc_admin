# loads all rake task of resque
require 'resque/tasks'

# # following statement is required only if your background task needs rails enviroment else skip it
# task "resque:setup" => :environment

# Start a worker with proper env vars and output redirection
def run_worker(num_workers = 1)
  env_vars = ENV.to_hash.slice("RAILS_ENV", "PIDFILE", "QUEUE")

  raise 'no Resque queues defined in ENV["QUEUE"] - nothing to do!' unless env_vars["QUEUE"]

  puts "Starting #{num_workers} worker(s) with QUEUE: #{env_vars['QUEUE']}"
  ops = {:pgroup => true, :err => [File.join(Rails.root, "log/resque_err.log"), "a"], 
                          :out => [File.join(Rails.root + "log/resque_stdout.log"), "a"]}
  num_workers.to_i.times {
    ## Using Kernel.spawn and Process.detach because regular system() call would
    ## cause the processes to quit when capistrano finishes
    pid = spawn(env_vars, "rake resque:work", ops)
    Process.detach(pid)
  }
end

namespace :resque do 
  task :setup => :environment do
    Resque.before_fork = Proc.new { 
      ActiveRecord::Base.establish_connection

      # Open the new separate log file
      logfile = File.open(File.join(Rails.root, 'log', 'resque.log'), 'a')

      # Activate file synchronization
      logfile.sync = true

      # Create a new buffered logger
      Resque.logger = ActiveSupport::BufferedLogger.new(logfile)
      Resque.logger.level = Logger::WARNING
    }
  end
 
  # desc "Restart running workers"
  # task :restart_workers => :environment do
  #   Rake::Task['resque:stop_workers'].invoke
  #   Rake::Task['resque:start_workers'].invoke
  # end
  
  desc "Quit running workers"
  task :stop_workers => :environment do
    pids = Array.new
    Resque.workers.each do |worker|
      pids.concat(worker.worker_pids)
    end
    if pids.empty?
      puts "No workers to kill"
    else
      syscmd = "kill -s QUIT #{pids.join(' ')}"
      puts "Running syscmd: #{syscmd}"
      system(syscmd)
    end
  end
  
  desc 'Start workers - takes optional [num_workers]'
  task :start_workers, [:num_workers] => [:environment] do |t, args|
    args.with_defaults(:num_workers => 1)

    run_worker(args.num_workers)
  end
 end