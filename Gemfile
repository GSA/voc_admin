source 'http://rubygems.org'

# 3.0 stable as of March 15, 2013, see https://github.com/rails/rails/commits/3-0-stable
gem 'rails', :git => 'git://github.com/rails/rails.git', :ref => '77403a9'

# Authentication:
gem 'authlogic'
# openam: add your key to bitbucket per instructions here:
#  https://confluence.atlassian.com/pages/viewpage.action?pageId=270827678
gem 'openam', :git => "git@bitbucket.org:ctacdevteam/ams_sso.git"
# gem 'httparty' <-- should no longer need explicit inclusion with SSO gemified

gem 'memcache-client'
gem 'paperclip'
gem 'jquery-rails'
gem 'kaminari'

# OLD! Delayed_Job for asynchronous processing
# gem 'delayed_job_active_record'
# gem 'daemons', :require => false

# NEW: Resque
gem 'resque'
gem 'resque_mailer'
gem 'resque_unit', :group => :test

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
  gem 'pry-rails'
  gem 'yard'
  gem 'better_errors'
  gem 'binding_of_caller'
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
  
end
