require "simplecov"
SimpleCov.start "rails"

ENV["RAILS_ENV"] = "test"

require File.expand_path("../config/environment", __dir__)
require "rails/test_help"
require "shoulda-context"
require "minitest/autorun"
require "mocha/minitest"
require "webmock/minitest"

DatabaseCleaner.strategy = :transaction

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
      user: user,
    )
  end

  teardown do
    DatabaseCleaner.clean
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
