CommentToolApp::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => "localhost:3000" }
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

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
