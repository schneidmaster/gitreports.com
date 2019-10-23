FROM ruby:2.4.5

# Install redis, sudo, nodejs, and yarn
RUN apt-get update && apt-get -y install redis-server sudo
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
RUN sudo apt-get install -y nodejs
RUN npm install -g yarn

# Set up working dir
RUN mkdir /app
WORKDIR /app

# Install gems
RUN gem install foreman

# Install app dependencies
COPY Gemfile Gemfile.lock /app/
RUN bundle
RUN bundle install -j 8
COPY package.json yarn.lock /app/
RUN yarn install

# Copy app files
COPY . /app/

# Expose port 5000 from within the container to the world
EXPOSE 5000
EXPOSE 3808

ENV HOST 0.0.0.0
ENV WEBPACK_DEV_HOST 0.0.0.0

# Start the Rails and webpack servers
CMD redis-server --daemonize yes && bundle exec rails db:migrate && foreman start -f Procfile.dev
