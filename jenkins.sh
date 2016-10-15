#!/bin/bash -x
export RAILS_ENV=test
export DISPLAY=":99"

git clean -fdx

bundle install --path "/home/jenkins/bundles/${JOB_NAME}" --deployment

bundle exec govuk-lint-ruby \
  --format html --out rubocop-${GIT_COMMIT}.html \
  --format clang \
  app config Gemfile lib spec || linting_error=1

bundle exec rake db:drop db:create db:schema:load
bundle exec rake assets:clean assets:precompile
bundle exec rake ci:setup:minitest default
