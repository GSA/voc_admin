CommentToolApp::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Paperclip S3 configuration.
  # Uncomment this section to use s3 in development
  #  config.paperclip_defaults = {
  #    storage: :s3,
  #    bucket: ENV.fetch('S3_BUCKET_NAME'),
  #    path: "#{ENV.fetch('S3_PATH_PREFIX')}/:filename",
  #    s3_permissions: :private
  #  }

  # Comment out this section if using S3 to store files
  config.paperclip_defaults = {
    :path => ":rails_root/exports/:filename",
    :url  => "/exports/:access_token/download"
  }

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => "localhost:3000" }
  config.action_mailer.delivery_method = :file

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.eager_load = false

end


 # Populate the @@subclasses variable for DisplayField to
 # allow the select menu to be populated correctly  in development
 # environment.  A way around lazy loading in development.
def bootstrap_display_field_callbacks
  p "eager loading display field subclasses"
  files = Dir.glob("app/models/display_field_models/*.rb")
  files.map{|x| x.split('/').last.split('.').first}.each do |f|
    f.classify.constantize.nil?
  end
end

# Run once on startup after Rails environment is all warmed up and
# ready to rock.
CommentToolApp::Application.configure do
  config.after_initialize do
    bootstrap_display_field_callbacks
  end
end

# Schedule it to be called after every reload!
ActionDispatch::Callbacks.after do
  bootstrap_display_field_callbacks
end

Rails.application.routes.default_url_options[:protocol] = 'https'
