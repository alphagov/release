#!/bin/bash -x
bundle install --path "/home/jenkins/bundles/${JOB_NAME}" --deployment
RAILS_ENV=test bundle exec rake spec assets:clean assets:precompile
RESULT=$?
exit $RESULT
