require "test_helper"
require "capybara/rails"
require "webmock"

Capybara.javascript_driver = :poltergeist
DatabaseCleaner.strategy = :truncation
WebMock.disable_net_connect!(allow_localhost: true)

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include WebMock::API
  include Warden::Test::Helpers

  setup do
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def login_as_stub_user
    @current_user = FactoryBot.create(:user)
    GDS::SSO.test_user = @current_user
  end
end


class JavascriptIntegrationTest < ActionDispatch::IntegrationTest
  self.use_transactional_tests = false
  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end
end
