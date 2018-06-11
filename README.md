# Release

[![Build Status](https://travis-ci.org/alphagov/release.png)](https://travis-ci.org/alphagov/release)

An application to make managing releases to specific environments easier.

## Getting started

1. Create app-specific mysql user (check [config/database.yml](config/database.yml) for user details):

    ```
    mysql.server start
    mysql -u root

    # Create release user
    CREATE USER 'release'@'localhost' IDENTIFIED BY 'release';
    GRANT ALL PRIVILEGES
    ON `release_%`.*
    TO 'release'@'localhost'
    WITH GRANT OPTION;
    FLUSH PRIVILEGES;
    exit
    ```

2. Install dependencies, create databases and run initial migrations, test:
    ```
    bundle install
    bundle exec rake db:create:all db:migrate
    bundle exec rake
    ```
3. Create applications in [db/seeds.rb](db/seeds.rb):

    ```
    bundle exec rake db:seed
    ```
