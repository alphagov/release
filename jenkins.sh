#!/bin/bash -x
export RAILS_ENV=test
bundle install --path "/home/jenkins/bundles/${JOB_NAME}" --deployment
bundle exec rake db:drop db:create db:schema:load
bundle exec rake ci:setup:rspec spec assets:clean assets:precompile
bundle exec rake test
