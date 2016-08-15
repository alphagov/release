#!/bin/bash

bundle install
bundle exec rails server unicorn -b 0.0.0.0 -p 3036
