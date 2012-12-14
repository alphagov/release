# Release

An application to make managing releases to specific environments easier.

## Getting started

You will need a SQL database and may have to create an app-specific SQL user - check `config/database.yml` for user details.

    bundle install
    rake db:create db:migrate
    rake spec
    rake test

Create applications in db/seeds.rb

    rake db:seed

## Github API

You will need to generate an OAuth token and put it in `config/github_credentials.yml`. See the [Github API docs](http://developer.github.com/v3/oauth/) for some instructions.
