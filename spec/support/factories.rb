FactoryGirl.define do
  factory :release do
    notes "release notes"
    deploy_at { Date.today }

    after(:build) do |release|
      release.tasks << FactoryGirl.build(:task, :release_id => release.id)
    end
  end

  factory :task do
    application
    sequence :version
    notes "deploy this"
  end

  factory :application do
    sequence(:name) {|n| "Application #{n}"}
    sequence(:repo) {|n| "alphagov/application-#{n}" }
  end

  factory :user do
    name "Winston Smith-Churchill"
    sequence(:email) {|n| "winston-#{n}@gov.uk" }
    permissions { Hash[GDS::SSO::Config.default_scope => ["signin"]] }
  end
end
