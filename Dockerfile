FROM ruby:2.4.5

RUN mkdir /app
WORKDIR /app

# Install gems
RUN gem install foreman
ADD Gemfile Gemfile.lock /app/
RUN bundle install -j 8

# Copy app files
ADD . /app

# Install redis, sudo, nodejs, and yarn
RUN apt-get update && apt-get -y install redis-server && apt-get install -y sudo
RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
RUN sudo apt-get install -y nodejs
RUN npm install -g yarn

# Install app dependencies
RUN yarn install
RUN bundle
RUN rake db:migrate

# Start the Rails and webpack servers
CMD foreman start -f Procfile.dev
