ENV["RAILS_ENV"] = "test"

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'shoulda-context'
require 'minitest/autorun'
require 'mocha/setup'

class ActiveSupport::TestCase
  def stub_user
    @stub_user ||= FactoryGirl.create(:user, :name => 'Stub User')
  end

  def login_as_stub_user
    stub_warden_as stub_user
  end

  def stub_warden_as(user)
    request.env['warden'] = stub(
      :authenticate! => true,
      :authenticated? => true,
      :user => user
    )
  end
end
