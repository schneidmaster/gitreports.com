source 'https://rubygems.org'

gem 'rails', '5.1'
gem 'webpack-rails'

gem 'high_voltage', '~> 3.0.0'
gem 'http_accept_language'
gem 'meta-tags'
gem 'newrelic_rpm'
gem 'octokit', '4.6.2'
gem 'redcarpet'
gem 'sidekiq', '3.4.2'
gem 'sidekiq-status', '0.6.0'
gem 'simple_captcha2', require: 'simple_captcha'
gem 'sinatra'
gem 'valid_email', require: 'valid_email/validate_email'

group :production do
  gem 'passenger', '~> 5.1'
  gem 'pg'
  gem 'rails_12factor'
end

group :development do
  # Use sqlite3 as the database for Active Record
  gem 'better_errors', '1.1.0'
  gem 'binding_of_caller', '0.7.2'
  gem 'rubocop'
  gem 'sqlite3', '1.3.10'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'codeclimate-test-reporter', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'poltergeist'
  gem 'rack_session_access'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'webmock'
end

group :development, :test do
  gem 'byebug'
  gem 'dotenv-rails', '0.9.0'
end
