# Release

An application to make managing releases to specific environments easier.

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

## Testing the kubernetes API view locally

* You will need to update the `Trust relationship` for the `release-assumed` role on the AWS `IAM` control panel using your `fulladmin` account on the `integration` environment. The additional trusted entity that you are adding should look like this - 

```
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::1234567890:role/your.name-developer"
            },
            "Action": "sts:AssumeRole"
        }
```

This step needs to be repeated for the `staging` environment as the app will show the status for both `integration` and `staging` environments. 
Note that the `production` environment is not updated in order to reduce the risk of affecting the `production` environment if the allowable actions on the kubernetes API should change in the future.

Note that the `production` environment is not updated in order to reduce the risk of affecting the `production` environment if the allowable actions on the kubernetes API changes in the future.

* Once the extra trust entity has been added you should be able to run the Release app locally after [assuming your developer account](https://docs.publishing.service.gov.uk/kubernetes/get-started/access-eks-cluster/#obtain-aws-credentials-for-your-role-in-the-clusters-aws-account).

**Use GOV.UK Docker to run any commands that follow.**

### To the run the tests

```
bundle exec rake
```

### Architecture diagrams

- [High-level architecture](https://drive.google.com/file/d/12iUDHvNKi_7_dmNC1cE0-cbViB05Cr2o/view)
- [ERD/Domain model](https://drive.google.com/file/d/1JfPhTwR3IBvBv0O9dCjZhlLgivhkC7aE/view)

## Licence

[MIT License](LICENCE)

