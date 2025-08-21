# Release

An application to make managing releases to specific environments easier.

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

## Seeing the kubernetes API view running locally

To see the kubernetes API view you will need to run the `Release` app on your machine, not in the `govuk-docker` stack.
If you are just running the tests you can use `govuk-docker`.

* Before running the app you will need to update the `Trust relationship` for the `release-assumed` role on the AWS `IAM` control panel using your `fulladmin` account on the `integration` environment. The additional trusted entity that you are adding should look like this -

```json
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::1234567890:role/your.name-developer"
            },
            "Action": "sts:AssumeRole"
        }
```

This step needs to be repeated for the `staging` environment as the app will show the status for both `integration` and `staging` environments.

Note that the `production` environment is not updated in order to reduce the risk of affecting the `production` environment if the allowable actions on the kubernetes API changes in the future.

* Finally on the `AWS console` you will also need to add the following IAM policy to your developer role in `integration`. Under the AWS `IAM` control panel using your `fulladmin` account, select your developer role and then add a new permission using `Create inline policy` and switch to `JSON` so that you can paste the following json block -

```json
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Action": [
    "sts:AssumeRole"
   ],
   "Resource": "arn:aws:iam::210287912431:role/release-assumed"
  },
  {
   "Effect": "Allow",
   "Action": [
    "sts:AssumeRole"
   ],
   "Resource": "arn:aws:iam::696911096973:role/release-assumed"
  }
 ]
}
```

Click on `Next` to name your new policy, it should probably be something like `TestAssumeRole` and finally you should be able to click on `Create policy`.

* Once the extra trust entity and IAM policy has been added you should be able to run the Release app locally after [assuming your developer account](https://docs.publishing.service.gov.uk/kubernetes/get-started/access-eks-cluster/#obtain-aws-credentials-for-your-role-in-the-clusters-aws-account).

* Then ensure that you have `mysql server` running on your machine.

```sh
brew install mysql # needed if you don't have mysql installed already
mysql.server start
```

* Install the dependencies

```sh
npx yarn install # needed if you don't have yarn install already
```

```sh
bundle install
```

* Setup the database

```sh
DATABASE_URL="mysql2://root@localhost/release_development" bin/rails db:setup
```

```sh
rails assets:precompile # ensure that you have yarn installed
```

* Start the Rails server

```sh
DATABASE_URL="mysql2://root@localhost/release_development" rails s
```

* Run a single test

```sh
DATABASE_URL="mysql2://root@localhost/release_development" rake db:seed
DATABASE_URL="mysql2://root@localhost/release_development"  rake test TEST=test/integration/deploy_page_test.rb
```

**Use GOV.UK Docker to run any commands that follow.**

### To the run the tests

```sh
bundle exec rake
```

### Architecture diagrams

* [High-level architecture](https://drive.google.com/file/d/12iUDHvNKi_7_dmNC1cE0-cbViB05Cr2o/view)
* [ERD/Domain model](https://drive.google.com/file/d/1JfPhTwR3IBvBv0O9dCjZhlLgivhkC7aE/view)

## Licence

[MIT License](LICENCE)
