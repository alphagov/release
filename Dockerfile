FROM ruby:2.7.6
MAINTAINER "govuk-role-platform-accounts-members@digital.cabinet-office.gov.uk"

# Add yarn to apt sources
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
      # base dependencies
      ruby-dev build-essential libgmp3-dev default-libmysqlclient-dev \
      # for bundle exec rake -T and assets commands to work
      curl -sL https://deb.nodesource.com/setup_16.x | bash - \
      apt-get update -qq && apt-get install -y nodejs \
      # for healthcheck
      curl \
      yarn

COPY . .

RUN bundle install
RUN bundle exec rake assets:clean assets:precompile

HEALTHCHECK --interval=15s --timeout=3s\
  CMD curl -f http://localhost:3036/ || exit 1

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3036"]

EXPOSE 3036
