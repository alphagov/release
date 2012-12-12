class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  before_filter :require_signin_permission!

  protect_from_forgery

  before_filter :set_cache

  def error_400; error 400; end
  def error_404; error 404; end

  rescue_from ActiveRecord::RecordNotFound, with: :error_404

  private

  def error(status_code)
    render status: status_code, text: "#{status_code} error"
  end

  def set_cache
    unless Rails.env.development?
      expires_in 5.minutes, :public => true
    end
  end
end
