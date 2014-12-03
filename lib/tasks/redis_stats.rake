namespace :logging do
  desc "Log Redis and Resque stats"
  task :resque_status => [:environment] do
    LOGGER = Logger.new("#{Rails.root}/log/resque_status.log")
    LOGGER.level = Logger::INFO

    original_formatter = Logger::Formatter.new
    LOGGER.formatter = proc { |severity, datetime, progname, msg|
      original_formatter.call(severity, datetime, progname, msg.dump)
    }

    QueueStats = Struct.new(:name) do
      def size
        Resque.size(name)
      end
    end

    LOGGER.info("Resque Info: #{Resque.info.to_s}")

    queue_stats = Resque.queues.map {|q_name| QueueStats.new(q_name)}
    queue_stats.each {|qs| LOGGER.info("Redis Queue: #{qs.name} - #{qs.size} enqueued jobs waiting for processing")}
  end
end
