class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  before_action :require_signin_permission!, except: [:healthcheck]

  protect_from_forgery

  def error_400; error 400; end

  def error_404; error 404; end

  rescue_from ActiveRecord::RecordNotFound, with: :error_404

  def healthcheck
    status = {status: 'ok'}
    render json: status
  end

  def site_settings
    @site_settings ||= Site.settings
  end
  helper_method :site_settings

private

  def error(status_code)
    render status: status_code, text: "#{status_code} error"
  end

  def redirect_if_read_only_user
    redirect_to applications_path unless current_user.may_deploy?
  end
end
