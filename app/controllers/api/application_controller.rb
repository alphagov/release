class Api::ApplicationController < ActionController::API
  include ActionController::Helpers
  include GDS::SSO::ControllerMethods

  before_action :authenticate_user!
end
