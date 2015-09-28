FactoryGirl.define do
  factory :application do
    sequence(:name) {|n| "Application #{n}"}
    sequence(:repo) {|n| "alphagov/application-#{n}" }
    domain "mygithub.tld"
  end

  factory :deployment do
    sequence(:version) { |n| "release_#{n}" }
    environment "production"
  end

  factory :user do
    name "Stub User"
    sequence(:email) {|n| "winston-#{n}@gov.uk" }
    permissions { ["signin", "deploy"] }
  end
end
