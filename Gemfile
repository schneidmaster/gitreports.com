source 'https://rubygems.org'

gem 'rails', '5.1'
gem 'webpack-rails'

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
  gem 'sqlite3', '1.3.10'
  gem 'binding_of_caller', '0.7.2'
  gem 'better_errors', '1.1.0'
  gem 'rubocop', '0.24.1'
end

group :test do
  gem 'capybara', '~> 2.3.0'
  gem 'capybara-screenshot', '~> 0.3.19'
  gem 'codeclimate-test-reporter', require: false
  gem 'database_cleaner', '~> 1.3.0'
  gem 'factory_girl_rails', '~> 4.4.1'
  gem 'faker', '~> 1.3.0'
  gem 'poltergeist', '~> 1.5.0'
  gem 'rack_session_access', '~> 0.1.1'
  gem 'rspec-rails', '~> 3.1'
  gem 'simplecov', '~> 0.10.0'
  gem 'webmock', '~> 1.18.0'
end

group :development, :test do
  gem 'byebug'
  gem 'dotenv-rails', '0.9.0'
end
