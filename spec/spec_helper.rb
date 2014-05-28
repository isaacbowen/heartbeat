# code climate

if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end


# env

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __FILE__)

ActiveRecord::Migration.maintain_test_schema!


# rspec

require 'rspec/rails'
require 'rspec/autorun'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.order = 'random'
end


# capybara

require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.default_driver = :poltergeist

RSpec.configure do |config|
  config.after(:each) { Capybara.reset_sessions! }
end


# database cleaner

DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.before(:suite) { DatabaseCleaner.clean_with(:truncation) }
  config.before(:each)  { DatabaseCleaner.start }
  config.after(:each)   { DatabaseCleaner.clean }
end


# vcr

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.ignore_localhost = true
  config.hook_into :webmock
end
