source 'https://rubygems.org'
ruby '2.1.2'

gem 'rails', '4.1.1'
gem 'pg'
gem 'foreigner'
gem 'dalli'

gem 'sass-rails', '~> 4.0.3'
gem 'bootstrap-sass'
gem 'autoprefixer-rails'
gem 'font-awesome-sass'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'

gem 'haml'
gem 'stamp'
gem 'numbers_and_words'
gem 'liquid'

# auth
gem 'devise'
gem 'omniauth-google-oauth2'

# if auto-required, this will monkeypatch the crap out of Enumerable
gem 'descriptive_statistics', require: false

gem 'newrelic_rpm'

gem 'dotenv-rails'
gem 'dotenv-deployment'

group :development do
  gem 'annotate'
  
  gem 'spring'
  gem 'spring-commands-rspec'

  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'guard'
  gem 'guard-rspec'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'pry-rails'
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'timecop'
  gem 'codeclimate-test-reporter', require: nil
  gem 'quiet_assets'

  # http://collectiveidea.com/blog/archives/2014/02/11/false-positives-on-travis-ci-with-codeclimate-simplecov/
  gem 'simplecov', '~> 0.7.1', require: nil
end

group :test do
  gem 'webmock'
  gem 'vcr'
end
