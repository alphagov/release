require 'simplecov'
require 'simplecov-rcov'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start 'rails'

ENV["RAILS_ENV"] = "test"

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'shoulda-context'
require 'minitest/autorun'
require 'mocha/setup'
require 'webmock/minitest'

DatabaseCleaner.strategy = :transaction

module SharedTests
  def shared_test_for(test_name, &block)
    @@shared_tests ||= {}
    @@shared_tests[test_name] = block
  end

  def shared_test(test_name, scenario, *args)
    define_method "test_#{test_name}_for_#{scenario}" do
      instance_exec *args, &@@shared_tests[test_name]
    end
  end
end

class ActiveSupport::TestCase
  extend SharedTests

  setup do
    DatabaseCleaner.start
  end

  shared_test_for "actions_requiring_deploy_permission_redirect" do |method, action, params|
    params ||= {}
    login_as_read_only_stub_user
    send(method, action, params)
    assert_redirected_to "/applications"
  end

  def stub_user
    @stub_user ||= FactoryGirl.create(:user, :name => 'Stub User')
  end

  def read_only_stub_user
    @read_only_stub_user ||= FactoryGirl.create(:user, 
                                                {
                                                  :name => 'Stub User', 
                                                  :permissions => ['signin']
                                                })
  end

  def login_as_stub_user
    stub_warden_as stub_user
  end

  def login_as_read_only_stub_user
    stub_warden_as read_only_stub_user
  end

  def stub_warden_as(user)
    request.env['warden'] = stub(
      :authenticate! => true,
      :authenticated? => true,
      :user => user
    )
  end

  teardown do
    DatabaseCleaner.clean
  end
end
