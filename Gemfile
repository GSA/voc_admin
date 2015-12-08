source 'http://rubygems.org'

gem 'rails', '3.2.21'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'jquery-rails'
gem 'kaminari'
gem 'delayed_job_active_record'
gem 'authlogic'
gem 'memcache-client'
gem 'paperclip'
gem 'daemons', :require => false

gem 'openam', :git => "git@bitbucket.org:ctacdevteam/ams_sso.git", :tag => '0.5.4'

gem 'resque_mailer'
gem 'resque-status'
gem 'resque_unit', :group => :test

gem 'bson_ext'
gem 'escape_utils'
gem 'mongoid'
gem 'open_uri_redirections'
gem "ranked-model", "~> 0.2.1"
gem 'redis-objects'
gem 'pdfkit'
gem "best_in_place"#, :git => 'https://github.com/eLafo/best_in_place', :branch => 'rails-3.0' # This version is require for < Rails 3.1
gem 'httparty'

gem 'elasticsearch' #using base elasticsearch gem for now.  we may want to use model later, but this isn't a traditional use case of search

gem 'test-unit'

# Needed for the new asset pipeline
group :assets do
  gem 'sass-rails', '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier', '>= 1.0.3'
end

platform :ruby do
  gem 'unicorn-rails'
  gem 'mysql2', '~> 0.3'
  gem 'wkhtmltopdf-binary', "~> 0.9.9.1"

  group :test do
    gem 'rails_best_practices'
  end
end

platform :jruby do
  gem 'activerecord-jdbc-adapter'
  gem 'jdbc-mysql'
  gem 'activerecord-jdbcmysql-adapter'

  gem 'jruby-openssl', :require => false

  gem 'jruby-rack', :require => false
  gem 'jruby-rack-worker', :require => false

  gem 'warbler'
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'yard'
end

group :development, :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails'
end

group :test do
  gem 'simplecov', :require => false
  gem 'database_cleaner'
  gem 'capybara'
  gem "capybara-webkit"
  gem 'guard-rspec'
  gem 'growl'
  gem 'shoulda-matchers'
  gem 'rb-fsevent', '~> 0.9.1'
end
