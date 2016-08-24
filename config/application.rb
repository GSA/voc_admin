# Set RAILS_RELATIVE_URL_ROOT if not installing as root application on a domain
#ENV['RAILS_RELATIVE_URL_ROOT'] = "/vocsub"

require File.expand_path('../boot', __FILE__)
require 'csv'
require 'rails/all'
require 'pdfkit'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CommentToolApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{Rails.root}/lib)

    config.generators.orm :active_record

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
    config.active_record.observers = :question_content_observer, :display_field_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.autoload_paths += Dir["#{config.root}/app/models/**/"]

    # This is suppose to cause the dig tag "field with errors" from breaking the styling.
    config.action_view.field_error_proc = Proc.new { |html_tag, instance| "#{html_tag}".html_safe }

    # config.action_controller.relative_url_root = '/vocsub'

    # Required configuration for the asset pipeline
    config.assets.enabled = true
    config.assets.version = '1.0'
    # Added by Jake, 7/5/2016: tag logging for Docker
    config.log_level = :debug
    config.log_tags  = [:subdomain, :uuid]

    config.middleware.use PDFKit::Middleware, {}, :only => %r[/pdf/]
  end
end
