# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'capybara/rails'
require 'authlogic/test_case'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include Authlogic::TestCase
  config.include FeatureHelper, type: :feature
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!

  config.before(:each) do |example|
    if Role::ADMIN.nil?
      Role.remove_const ADMIN
    end
    add_execution_triggers
    truncate_elasticsearch_index
  end

  # DatabaseCleaner Configuration
  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:redis].strategy = :truncation
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:each) do |example|
    DatabaseCleaner[:active_record].strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do |example|
    DatabaseCleaner.clean
  end

  def add_execution_triggers
    %w(add update delete nightly).each_with_index do |trigger, index|
      ExecutionTrigger.find_or_create_by(name: trigger) do |et|
        et.id = index + 1
      end
    end
  end

  def truncate_elasticsearch_index
    ELASTIC_SEARCH_CLIENT.indices.delete index: ELASTIC_SEARCH_INDEX_NAME
    ELASTIC_SEARCH_CLIENT.indices.create index: ELASTIC_SEARCH_INDEX_NAME,
      body: ELASTIC_SEARCH_MAPPINGS[:survey_responses]
  end
end
