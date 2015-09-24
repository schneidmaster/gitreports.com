[![Build Status](https://circleci.com/gh/schneidmaster/gitreports.com.svg?style=shield)](https://circleci.com/gh/schneidmaster/gitreports.com)
[![Test Coverage](https://codeclimate.com/github/schneidmaster/gitreports.com/badges/coverage.svg)](https://codeclimate.com/github/schneidmaster/gitreports.com/coverage)
[![Code Climate](https://codeclimate.com/github/schneidmaster/gitreports.com/badges/gpa.svg)](https://codeclimate.com/github/schneidmaster/gitreports.com)
[![security](https://hakiri.io/github/schneidmaster/gitreports.com/master.svg)](https://hakiri.io/github/schneidmaster/gitreports.com/master)

gitreports.com
================

Git Reports is a free service that lets you set up a stable URL for anonymous users to submit bugs and other Issues to your GitHub repositories.  It works with public and private repositories and personal and organization repositories.  It also provides some custom settings like Issue labels and messages to display to users submitting bugs.

Self-hosting
================

You're welcome to clone and self-host the application if you're so inclined.  Follow these steps:

1. Git Reports uses Sidekiq for background jobs. To enable processing of jobs on your local machine, you just need to have Redis installed and running. (If you installed Redis with Homebrew, execute `brew info redis` to retrieve the necessary command and then execute that command.) Then just run `bundle exec sidekiq` (use the `-d` flag to daemonize it).
2. Clone the application, `bundle`, and `rake db:migrate`.
3. Register your instance of the application with GitHub [here](https://github.com/settings/applications/new); this will give you an application client ID and client secret.
4. Git Reports uses dotenv for configuration.  Create a file in the application root directory named ".env" and add the following lines to it (filling in the values you got from the last step):

---

    GITHUB_CLIENT_ID=youridhere
    GITHUB_CLIENT_SECRET=yoursecrethere
    GITHUB_CALLBACK_URL=http://yourdomain.com/github_callback
    SECRET_TOKEN=some_token # should be at least 128 random chars

If you're developing locally with WEBrick or similar, your domain in the callback URL should include the port, i.e.

    GITHUB_CALLBACK_URL=http://localhost:3000/github_callback

Since GitHub only accepts one callback URL for registered applications, I found it useful to register a development instance and a production instance, and use separate .env files in development and production with the appropriate client id, client secret, and callback URL in each.

If you want to track the application with Google Analytics, create the property and add the tracking code to the .env file as follows:

    GOOGLE_ANALYTICS_CODE=UA-########-#

## Translations

The public-facing portions of the Git Reports UI support i18n translations. Presently, English and Polish are supported; the active locale is selected using the Accept-Location HTTP header. If you would like to contribute a translation, make a copy of `config/locales/en.yml` using the desired locale code (check the full list [here](http://www.roseindia.net/tutorials/I18N/locales-list.shtml)), translate the text, and submit a pull request.

## Contributing

1. Fork it ( https://github.com/schneidmaster/gitreports.com/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request