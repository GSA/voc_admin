source 'http://rubygems.org'

gem 'rails', '4.0.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'jquery-rails'
gem 'kaminari'
gem 'kaminari-mongoid'
gem 'delayed_job_active_record'
gem 'authlogic'
gem 'net-ldap'
gem 'memcache-client'
gem 'daemons', :require => false
gem 'paperclip'
gem 'aws-sdk', '< 2.0'

gem 'resque_mailer'
gem 'resque-status'
gem 'resque_unit', :group => :test

gem 'escape_utils'
gem 'mongoid', "~> 5.0"
gem 'open_uri_redirections'
gem "ranked-model", "~> 0.2.1"
gem 'redis-objects'
gem 'pdfkit'
gem "best_in_place"
gem 'httparty'
gem 'spreadsheet', '1.0.0'

gem 'elasticsearch' #using base elasticsearch gem for now.  we may want to use model later, but this isn't a traditional use case of search

gem 'test-unit'

gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier', '>= 1.0.3'
gem 'therubyracer'

gem "rails-observers"

gem 'mysql2', '~> 0.3.18'
gem 'unicorn-rails'
gem 'wkhtmltopdf-binary', "~> 0.9.9.1"

# Add attr_accessible back so we can slowly convert to strong parameters
gem "protected_attributes"

gem "dotenv-rails"

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem "byebug"
  gem 'yard'
  gem "pry-byebug"
  gem "pry-rails"
  gem "quiet_assets"

  gem "spring"
  gem "spring-commands-rspec"
end

group :development, :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails'
end

group :test do
  gem 'simplecov', :require => false
  gem 'database_cleaner'
  gem "capybara-webkit"
  gem "selenium-webdriver"
  gem "launchy"
  gem 'shoulda-matchers'
  gem "guard-rspec", require: false
end
