if Rails.env.production?
  Raven.configure do |config|
    config.dsn = ENV['SENTRY_DSN']

    config.excluded_exceptions = [
      'GithubRateLimitError',

      # Mostly bots trying WordPress URLs.
      'ActionController::RoutingError',

      # Revoked/expired credentials.
      'Octokit::Forbidden',
      'Octokit::Unauthorized'
    ]
  end
end
