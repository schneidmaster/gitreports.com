require 'codeclimate-test-reporter'
require 'simplecov'

SimpleCov.formatter = CodeClimate::TestReporter::Formatter if ENV['CIRCLE_ARTIFACTS']
SimpleCov.start 'rails' do
  add_filter '/workers/'
end

ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)

require 'rspec/rails'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'capybara/poltergeist'
require 'webmock/rspec'
require 'rack_session_access/capybara'
require 'sidekiq/testing'

WebMock.disable_net_connect!(allow_localhost: true, allow: %w(codeclimate.com))

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  # Include FactoryGirl helper methods
  config.include FactoryGirl::Syntax::Methods

  # Include SessionHelper methods
  config.include Features::SessionHelpers, type: :feature
  config.include Controllers::SessionHelpers, type: :controller

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  # Set up Capybara
  Capybara.configure do |capy|
    capy.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app)
    end
    capy.javascript_driver = :poltergeist
    capy.server_port = 5000
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # Stub GitHub requests
  config.before(:each) do
    stub_request(:any, /github.com/).to_rack(FakeGitHub)
  end

  # Ensure Sidekiq is empty
  config.before(:each) do
    Sidekiq::Worker.clear_all
  end
end
