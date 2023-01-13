require 'byebug'

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
    @deployments = Deployment.includes(:application).newest_first.limit(25)
  end

  def new
    default_deploy_time = Time.zone.now.strftime("%e/%m/%Y %H:%M")

    shortname = new_deployment_params[:application_id]

    application_id = Application.where(shortname: shortname).pick(:id)

    @deployment = Deployment.new(
      application_id: application_id,
      environment: new_deployment_params[:environment],
      created_at: default_deploy_time,
    )
  end

  def create
    if push_notification?

      application = if use_application_by_name
                      application_by_name
                    else
                      application_by_repo
                    end

      return if application.nil?

      application.archived = false
      application.save!
      Deployment.create!(deployment_params.merge(application: application))
      head :ok
    else
      @deployment = Deployment.new(deployment_params)
      if @deployment.save
        application = Application.find(deployment_params[:application_id])
        application.archived = false
        application.save!

        redirect_to application_path(application), notice: "Deployment created for #{application.name}"
      else
        render :new, status: :unprocessable_entity
      end

    end
  end

private

  def application_by_repo
    existing_apps = Application.where(repo: repo_path)

    case existing_apps.length
    when 0
      Application.create!(name: normalize_app_name(repo_path), repo: repo_path)
    when 1
      existing_apps[0]
    else
      raise ApplicationConflictError
    end
  end

  def application_by_name
    existing_apps = Application.where(name: normalize_app_name(params[:application_name]))

    if existing_apps.length.zero?
      Application.create!(name: normalize_app_name(params[:application_name]), repo: repo_path)
    elsif existing_apps.length == 1
      existing_apps[0]
    end
  end

  def repo_path
    if params[:repo].start_with?("http")
      URI.parse(params[:repo]).path.gsub(%r{^/}, "")
    elsif params[:repo].start_with?("git@")
      params[:repo].split(":")[-1].gsub(/.git$/, "")
    else
      params[:repo]
    end
  end

  def normalize_app_name(unnormalized_app_name)
    normalized_app_name = unnormalized_app_name.split("/")[-1].tr("-", " ").humanize.titlecase
    normalized_app_name.gsub(/\bApi\b/, "API")
  end

  def push_notification?
    params[:repo].present?
  end

  def use_application_by_name
    params.fetch(:application_by_name, nil) == "true"
  end

  def deployment_params
    params.require(:deployment).permit(
      :application,
      :application_id,
      :created_at,
      :deployed_sha,
      :environment,
      :id,
      :jenkins_user_email,
      :jenkins_user_name,
      :repo,
      :version,
    )
  end

  def new_deployment_params
    params.permit(
      :application_id,
      :environment,
    )
  end
end
