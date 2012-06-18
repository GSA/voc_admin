source 'http://rubygems.org'

gem 'rails', '3.0.12'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'jquery-rails'
gem 'thin'
gem 'kaminari'
gem 'delayed_job', '2.1.4'
gem 'authlogic'
gem 'memcache-client'

gem 'unicorn-rails'

group :development do 
	gem 'annotate'
	gem 'metrical'
	gem 'pry-rails'
end

gem 'rspec-rails', :group => [:development, :test]

group :test do
  gem 'simplecov', :require => false
  gem 'factory_girl_rails'
  gem 'guard-rspec'
  gem 'growl'
end

group :mysql_db do
	gem 'mysql2', '< 0.3'
end
