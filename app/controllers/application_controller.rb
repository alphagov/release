class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  layout 'admin_layout'

  before_action :authenticate_user!, except: [:healthcheck]

  protect_from_forgery

  def error_400; error 400; end

  def error_404; error 404; end

  rescue_from ActiveRecord::RecordNotFound, with: :error_404

  def healthcheck
    status = { status: 'ok' }
    render json: status
  end

  def site_settings
    @site_settings ||= Site.settings
  end
  helper_method :site_settings

  before_action do
    response.headers[Slimmer::Headers::SKIP_HEADER] = "true"
  end

private

  def error(status_code)
    render status: status_code, text: "#{status_code} error"
  end

  def redirect_if_read_only_user
    redirect_to applications_path, notice: 'You do not have permission to do that' unless current_user.may_deploy?
  end
end
