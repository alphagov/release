class DeploymentsController < ApplicationController
  class ApplicationConflictError < RuntimeError; end

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

private

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
      :deployed_sha,
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
end
