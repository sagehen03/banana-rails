FROM rubylang/ruby:2.6.3-bionic
RUN apt-get update -qq && apt-get -y install postgresql-client libpq5 libpq-dev
RUN mkdir /banana-rails
WORKDIR /banana-rails

# gem install
COPY Gemfile /banana-rails/Gemfile
COPY Gemfile.lock /banana-rails/Gemfile.lock
RUN bundle install
RUN gem install pg -v '1.1.4' --source 'https://rubygems.org/'

COPY . /banana-rails

# executable
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
