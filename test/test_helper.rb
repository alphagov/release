require "simplecov"
SimpleCov.start "rails"

ENV["RAILS_ENV"] = "test"

require File.expand_path("../config/environment", __dir__)
require "rails/test_help"
require "shoulda-context"
require "minitest/autorun"
require "mocha/minitest"
require "webmock/minitest"
require "govuk_sidekiq/testing"

DatabaseCleaner.strategy = :transaction
Sidekiq::Testing.fake!

class ActiveSupport::TestCase
  setup do
    DatabaseCleaner.start
  end

  def stub_user
    @stub_user ||= FactoryBot.create(:user, name: "Stub User")
  end

  def login_as_stub_user
    stub_warden_as stub_user
  end

  def stub_warden_as(user)
    request.env["warden"] = stub(
      authenticate!: true,
      authenticated?: true,
      user:,
    )
  end

  teardown do
    DatabaseCleaner.clean
    Sidekiq::Worker.clear_all
  end
end

class ActionView::TestCase
  setup do
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
  end
end
