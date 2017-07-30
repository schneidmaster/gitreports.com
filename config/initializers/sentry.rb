if Rails.env.production?
  Raven.configure do |config|
    config.dsn = ENV['SENTRY_DSN']
  end
end
