source 'http://rubygems.org'

gem 'rails', :git => 'git://github.com/rails/rails.git', :ref => '182d4e3719' # 3.0.21, see https://github.com/rails/rails/pull/9126

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'jquery-rails'
gem 'kaminari'
gem 'delayed_job_active_record'
gem 'authlogic'
gem 'memcache-client'
gem 'paperclip'
gem 'daemons', :require => false

gem 'resque_mailer'
gem 'resque-status'
gem 'resque_unit', :group => :test
 
gem 'bson_ext'
gem 'escape_utils'
gem 'mongoid'
gem "ranked-model", "~> 0.2.1"
gem 'redis-objects'
gem 'shrimp'

platform :ruby do
  gem 'unicorn-rails'
  gem 'mysql2', '< 0.3'
  
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
  gem 'jazz_hands'
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
  gem 'shoulda-matchers'
  gem 'rb-fsevent', '~> 0.9.1'
  
end
