namespace :memcache do
  desc "Start Memcache server"
  task :start do
    raise "Memcached already running" if File.exists?(pid_path)

    print "starting memcache..."
    `memcached -d -vv -l 127.0.0.1 -p 11211 -P #{pid_path}  >> #{log_path} 2>&1`
    sleep(2.seconds)
    puts (File.exists?(pid_path) ? "done" : "Memcached failed to start")

  end

  task :stop do
    raise "Memcached does not seem to be running." unless File.exists?(pid_path)
    puts "stopping memcache..."
    `kill -9 \`cat #{pid_path}\``
    `rm #{pid_path}`

  end

  private
  def pid_path
    File.join(Rails.root,'tmp','pids','memcache.pid')
  end

  def log_path
    File.join(Rails.root,'log','memcache.log')
  end
end
