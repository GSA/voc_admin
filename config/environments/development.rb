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

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  
 # Populate the @@subclasses variable for DisplayField to 
 # allow the select menu to be populated correctly  in development
 # environment.  A way around lazy loading in development.
 %w[display_field display_field_boolean display_field_choice_multiselect display_field_choice_single
    display_field_currency_integer display_field_currency display_field_date display_field_email 
    display_field_float display_field_integer display_field_percent display_field_person display_field_phone 
    display_field_rtf display_field_text_multi display_field_text display_field_url_as_link 
    display_field_url display_field_value].each do |c|
   require_dependency File.join(Rails.root,"app", "models", "display_field_models", "#{c}.rb")
 end
end

