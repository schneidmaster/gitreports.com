![](https://travis-ci.org/schneidmaster/gitreports.com.svg?branch=master)

gitreports.com
================

Git Reports is a free service that lets you set up a stable URL for anonymous users to submit bugs and other Issues to your GitHub repositories.  It works with public and private repositories and personal and organization repositories.  It also provides some custom settings like Issue labels and messages to display to users submitting bugs.

Self-hosting
================

You're welcome to clone and self-host the application if you're so inclined.  Follow these steps:

1. Make sure [bower](https://bower.io) is installed on your system- the app uses it for frontend asset management. Rake automatically installs assets when your app launches.
2. Do normal Railsy things- clone the application, bundle install, copy config/database.example.yml to config/database.yml and set up your database credentials, run rake db:migrate.
3. Strip out the personal branding and PayPal Donate button.  Leave a link to my website in the About page if you want to be nice :)
4. Register your instance of the application with GitHub [here](https://github.com/settings/applications/new); this will give you an application client ID and client secret.
5. Rename config/initializers/secret_token.example.rb to config/initializers/secret_token.rb, and replace the #### with a long alphanumeric string- this is used to generate tokens to sign your application's cookies.
6. Git Reports uses dotenv for configuration.  Create a file in the application root directory named ".env" and add the following lines to it (filling in the values you got from the last step):

    GITHUB_CLIENT_ID=youridhere
    GITHUB_CLIENT_SECRET=yoursecrethere
    GITHUB_CALLBACK_URL=http://yourdomain.com/github_callback

If you're developing locally with WEBrick or similar, your domain in the callback URL should include the port, i.e. 

    GITHUB_CALLBACK_URL=http://localhost:3000/github_callback

Since GitHub only accepts one callback URL for registered applications, I found it useful to register a development instance and a production instance, and use separate .env files in development and production with the appropriate client id, client secret, and callback URL in each.

If you want to track the application with Google Analytics, create the property and add the tracking code to the .env file as follows:

    GOOGLE_ANALYTICS_CODE=UA-########-#

And that's it!  If you happen to add any neat features, send me a [pull request](https://help.github.com/articles/creating-a-pull-request).
