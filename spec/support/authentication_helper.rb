module AuthenticationHelper
  def login_as_stub_user
    current_user = FactoryBot.create(:user)
    GDS::SSO.test_user = current_user
  end
end
