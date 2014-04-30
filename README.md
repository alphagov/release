# Release

[![Build Status](https://travis-ci.org/alphagov/release.png)](https://travis-ci.org/alphagov/release)
[![Dependency Status](https://gemnasium.com/alphagov/release.png)](https://gemnasium.com/alphagov/release)

An application to make managing releases to specific environments easier.

## Getting started

1. Add mysql databases with an app-specific user (check `config/database.yml` for user details):

    ```
    mysql.server start
    mysql -u root

    # development db
    CREATE DATABASE release_development;
    # test db
    CREATE DATABASE release_test;
    # create user and give it access to dbs
    CREATE USER 'release'@'localhost' IDENTIFIED BY 'release';
    GRANT SELECT,INSERT,UPDATE,DELETE,CREATE
    ON `release_%`.*
    TO 'release'@'localhost';
    FLUSH PRIVILEGES;
    ```

2. Install dependencies, run initial migrations, test:
    ```
    bundle install
    bundle exec rake db:create db:migrate
    bundle exec rake test
    ```
3. Create applications in db/seeds.rb:

    ```
    bundle exec rake db:seed
    ```
