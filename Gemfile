source 'http://rubygems.org'

gem 'rails', '3.0.6'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'jquery-rails'
gem 'thin'
gem 'kaminari'


group :development, :test do 
	gem 'ruby-debug19'
	gem 'nifty-generators'
	gem 'annotate-models'
end
gem "mocha", :group => :test

group :mysql_db do
	gem 'mysql2', '< 0.3'
end

group :oracle_db do
	gem 'ruby-oci8'
	gem 'activerecord-oracle_enhanced-adapter', '1.3.2'
end