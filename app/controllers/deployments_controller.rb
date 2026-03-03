class DeploymentsController < ApplicationController
  class ApplicationConflictError < RuntimeError; end

  skip_forgery_protection if: :api_request_to_create_deployment?

  rescue_from ApplicationConflictError do
    head :conflict
  end

  def index
    @application = Application.friendly.find(params[:application_id])
    @deployments = @application.deployments.newest_first.limit(100)
  end

  def show
    @deployment = Deployment.find(params[:id])
  end

  def recent
    env = recent_deployment_params[:environment_filter]

    filtered_deployments = env ? Deployment.where(environment: env) : Deployment
    @deployments = filtered_deployments.includes(:application).newest_first.limit(25)
  end

  def create
    application = application_by_repo

    return if application.nil?

    application.save!
    Deployment.create!(deployment_params.merge(application:))
    head :ok
  end

  def toggle_change_failure
    @deployment = Deployment.find(params[:id])

    unless @deployment.can_mark_as_change_failure?
      flash[:alert] = "Change failure marking is not enabled for this application or this is not a production deployment."
      redirect_to deployment_path(@deployment) and return
    end

    @deployment.update!(change_failure: !@deployment.change_failure)

    if @deployment.change_failure?
      send_change_failure_slack_notification(@deployment)
    end

    redirect_to deployment_path(@deployment)
  end

private

  def send_change_failure_slack_notification(deployment)
    application = deployment.application
    channel = application.slack_channel_deployment_notification

    return if channel.blank?

    message = build_change_failure_message(deployment)
    SlackPosterJob.perform_later(message, channel)
  end

  def build_change_failure_message(deployment)
    application = deployment.application
    "*Change Failure* for *#{application.name}*\n" \
      "Version: `#{deployment.version}`\n" \
      "View deployment: #{deployment_url(deployment)}"
  end

  def application_by_repo
    existing_apps = Application.where(name: normalize_app_name(repo_path))

    case existing_apps.length
    when 0
      Application.create!(name: normalize_app_name(repo_path))
    when 1
      existing_apps[0]
    else
      raise ApplicationConflictError
    end
  end

  def repo_path
    params[:repo].split("/")[-1]
  end

  def normalize_app_name(unnormalized_app_name)
    normalized_app_name = unnormalized_app_name.split("/")[-1].tr("-", " ").humanize.titlecase
    normalized_app_name.gsub(/\bApi\b/, "API")
  end

  def deployment_params
    params.require(:deployment).permit(
      :application,
      :application_id,
      :created_at,
      :environment,
      :id,
      :repo,
      :version,
    )
  end

  def recent_deployment_params
    params.permit(
      :environment_filter,
    )
  end

  def api_request_to_create_deployment?
    # Requests from Argo Workflow:
    # https://github.com/alphagov/govuk-helm-charts/blob/main/charts/argo-services/templates/workflows/notify-release/workflow.yaml
    GDS::SSO::ApiAccess.api_call?(request.env) && action_name == "create"
  end
end
