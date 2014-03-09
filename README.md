# Release

[![Build Status](https://travis-ci.org/alphagov/release.png)](https://travis-ci.org/alphagov/release)
[![Dependency Status](https://gemnasium.com/alphagov/release.png)](https://gemnasium.com/alphagov/release)

An application to make managing releases to specific environments easier.

## Getting started

You will need a SQL database and may have to create an app-specific SQL user - check `config/database.yml` for user details.

    bundle install
    bundle exec rake db:create db:migrate
    bundle exec rake test

Create applications in db/seeds.rb

    bundle exec rake db:seed
