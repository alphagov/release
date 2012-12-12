FactoryGirl.define do
  factory :release do
    notes "release notes"
  end

  factory :task do
    application
    sequence :version
    notes "deploy this"
  end

  factory :user do
    name "Winston Smith-Churchill"
    sequence(:email) {|n| "winston-#{n}@gov.uk" }
    permissions { Hash[GDS::SSO::Config.default_scope => ["signin"]] }
  end
end
