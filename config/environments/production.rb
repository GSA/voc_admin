CommentToolApp::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Paperclip S3 configuration
  config.paperclip_defaults = {
    storage: :s3,
    bucket: ENV.fetch('S3_BUCKET_NAME'),
    path: "#{ENV.fetch('S3_PATH_PREFIX')}/:filename",
    s3_permissions: :private
  }

  config.eager_load = true

  # Asset pipeline configuration
  config.assets.serve_static_assets = true
  config.assets.compile = true

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Precompile additional assets (application.js, application.css, and all
  # non-JS/CSS are already added)
  config.assets.precompile += %w( *.js *.css )

  # Force all access to the app over SSL, use Strict-Transport-Security,
  # and use secure cookies.
  # config.force_ssl = true

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  #config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # RAILS 3.2+:
  config.logger    = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Email Configuration is handled by the mailer_config.rb initializer and
  # mailer_settings.yml

  # Enable threaded mode (currently only in linux jruby and running in jruby_rack)
  config.threadsafe! if RUBY_PLATFORM == "java" and defined?(Rails::Server)

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Enable memcached
  #config.cache_store = :mem_cache_store, "#{MemcachedServerConfig::Server}:#{MemcachedServerConfig::Port}", { :namespace => 'VOC', :expires_in => 1.day, :compress => true }
end

Rails.application.routes.default_url_options[:protocol] = 'https'
