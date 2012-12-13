require 'test_helper'
require 'capybara/rails'
require 'webmock'

DatabaseCleaner.strategy = :transaction
WebMock.disable_net_connect!

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include WebMock::API
  include Warden::Test::Helpers

  setup do
    DatabaseCleaner.clean
  end

  teardown do
    DatabaseCleaner.clean
    Capybara.use_default_driver
  end

  def login_as_stub_user
    @current_user = FactoryGirl.create(:user)
    login_as(@current_user, :scope => :user)
  end
end

