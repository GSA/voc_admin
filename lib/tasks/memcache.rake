namespace :memcache do
  desc "Start Memcache server"
  task :start do
    
    `memcached -d  -l 127.0.0.1 -p 11211 -P #{pid_path}  >> #{log_path} 2>&1`
  end
  
  task :stop do
    `kill -9 \`cat #{pid_path}\``
    `rm #{pid_path}`
  end
  
  private
  def pid_path
    File.join(Rake.original_dir,'tmp','pids','memcache.pid')
  end
  
  def log_path
    File.join(Rake.original_dir,'log','memcache.log')
  end
end