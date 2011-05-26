source 'http://rubygems.org'

gem 'rails', '3.0.7'
gem 'rake', '0.8.7'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'jquery-rails'
gem 'thin'
gem 'kaminari'
gem 'delayed_job'
gem 'authlogic', :git => 'git://github.com/binarylogic/authlogic.git'

group :development do 
	gem 'ruby-debug19'
	gem 'nifty-generators'
	gem 'annotate-models'
	gem 'metrical'
	gem 'rails-erd'
	gem 'bullet'
end

gem 'rspec-rails', :group => [:development, :test]

group :mysql_db do
	gem 'mysql2', '< 0.3'
end

group :oracle_db do
	gem 'ruby-oci8'
	gem 'activerecord-oracle_enhanced-adapter', '1.3.2'
end
