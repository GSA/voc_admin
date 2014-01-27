namespace :unicorn do
  class FileDoesNotExist < Exception
  end

  desc "Start the unicorn server.  Use config/unicorn_config.rb if it exists."
  task :start, [:config_file] do |t, args|
    args[:config_file] ||= ENV['UNICORN_CONFIG']
    # Default to use config file in config/unicorn_config.rb if it exists
    args.with_defaults( :config_file => "#{Rails.root}/config/unicorn_config.rb")

    raise "Config file (#{args[:config_file]}) doesn't seem to exist" if args[:config_file].present? && !File.exists?(args[:config_file])

    puts "Starting unicorn server using config file: #{args[:config_file]}"
    sh "cd #{Rails.root} && bundle exec unicorn --daemonize #{args[:config_file].present? ? "--config-file #{args[:config_file]}" : "" }"
  end

  desc "Stop the unicorn server"
  task :stop do
    unicorn_signal :QUIT
  end

  desc "Restart the unicorn server"
  task :restart => [:stop, :start]

  desc "Increment number of worker processes"
  task(:increment) { unicorn_signal :TTIN }

  desc "Decrement number of worker processes"
  task(:decrement) { unicorn_signal :TTOU }

  desc "Transparent restart.  Uses USR2 signal to start a new master process which will allow the old workers to finish handling their work and then
  die off.  New requests will be handled by the new workers spawned by the updated master process."
  task(:transparent_restart) do
    old_pid = unicorn_pid
    puts "forking master process.."
    unicorn_signal :USR2
    puts "done."
    sleep(5)

    puts "killing old master process (if it still exists)."
    unicorn_signal :QUIT, old_pid
  end

  # Send the unicorn process the specified signal
  def unicorn_signal signal, pid = nil
    Process.kill signal, (pid || unicorn_pid)
  end

  # Read the unicorn pid from the pid file.
  # Raises ENOENT if the file doesn't exist
  def unicorn_pid
    begin
      File.read(ENV['UNICORN_PID'] || "#{Rails.root}/tmp/pids/unicorn.pid").to_i
    rescue Errno::ENOENT
      raise "Unicorn doesn't seem to be running"
    end
  end
end
