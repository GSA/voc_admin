source 'http://rubygems.org'

gem 'rails', '3.0.19'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'jquery-rails'
gem 'kaminari'
gem 'delayed_job_active_record'
gem 'authlogic'
gem 'memcache-client'
gem 'paperclip'
gem 'daemons', :require => false

platform :ruby do
  gem 'unicorn-rails'
  gem 'mysql2', '< 0.3'
end

platform :jruby do
  gem 'jruby-openssl', :require => false
  gem 'activerecord-jdbc-adapter'
  gem 'jdbc-mysql'
  gem 'activerecord-jdbcmysql-adapter'
  gem 'warbler'
end

group :development do
	gem 'annotate'
	gem 'pry-rails'
  gem 'yard'
end

gem 'rspec-rails', :group => [:development, :test]

group :test do
  gem 'simplecov', :require => false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'capybara'

  gem 'guard-rspec'
  gem 'growl'
  gem 'pry-rails'
  gem 'shoulda-matchers'
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'rails_best_practices'
end
