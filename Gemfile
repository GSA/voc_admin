source 'http://rubygems.org'

gem 'rails', '3.0.10'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'jquery-rails'
gem 'thin'
gem 'kaminari'
gem 'delayed_job', '2.1.4'
gem 'authlogic'

gem 'unicorn-rails'

group :development do 
	gem 'ruby-debug19'
	gem 'nifty-generators'
	gem 'annotate'
	gem 'metrical'
	gem 'rails-erd'
	gem 'bullet'
	gem 'pry'
	gem 'pry_debug'
end

gem 'rspec-rails', :group => [:development, :test]

group :test do
  gem 'simplecov', :require => false
  gem 'guard-rspec'
end

group :mysql_db do
	gem 'mysql2', '< 0.3'
end
