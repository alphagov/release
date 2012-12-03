#!/bin/bash -x
bundle install --path "/home/jenkins/bundles/${JOB_NAME}" --deployment
RAILS_ENV=test bundle exec rake db:create db:migrate db:test:prepare
RAILS_ENV=test bundle exec rake ci:setup:rspec spec assets:clean assets:precompile
RESULT=$?
exit $RESULT
