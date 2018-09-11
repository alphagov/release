require 'simplecov'
require 'simplecov-rcov'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start 'rails'

ENV["RAILS_ENV"] = "test"

require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'
require 'shoulda-context'
require 'minitest/autorun'
require 'mocha/setup'
require 'webmock/minitest'

DatabaseCleaner.strategy = :transaction

class ActiveSupport::TestCase
  setup do
    DatabaseCleaner.start
  end

  def actions_requiring_deploy_permission_redirect(method, action, params = {})
    login_as_read_only_stub_user
    send(method, action, params: params)
    assert_redirected_to "/applications"
  end

  def stub_user
    @stub_user ||= FactoryBot.create(:user, name: 'Stub User')
  end

  def read_only_stub_user
    @read_only_stub_user ||= FactoryBot.create(:user,
                                                name: 'Stub User',
                                                permissions: %w(signin))
  end

  def login_as_stub_user
    stub_warden_as stub_user
  end

  def login_as_read_only_stub_user
    stub_warden_as read_only_stub_user
  end

  def stub_warden_as(user)
    request.env['warden'] = stub(
      authenticate!: true,
      authenticated?: true,
      user: user
    )
  end

  teardown do
    DatabaseCleaner.clean
  end
end
