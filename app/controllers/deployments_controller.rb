class DeploymentsController < ApplicationController
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

    application_id = Application.where(shortname: shortname).pluck(:id).first

    @deployment = Deployment.new(application_id: application_id,
                                 environment: new_deployment_params[:environment],
                                 created_at: default_deploy_time)
  end

  def create
    if push_notification?
      application = application_by_repo
      application.archived = false
      application.save!
      Deployment.create!(deployment_params.merge(application: application))
      head 200
    else
      @deployment = Deployment.new(deployment_params)
      if @deployment.save
        application = Application.find(deployment_params[:application_id])
        application.archived = false
        application.save!
        redirect_to applications_path, notice: "Deployment created for #{application.name}"
      else
        flash[:alert] = "Failed to create deployment"
        render :new
      end
    end
  end

private

  def application_by_repo
    existing_apps = Application.where(repo: repo_path)
    if existing_apps.present?
      if existing_apps.length == 1
        existing_apps[0]
      else
        existing_apps = Application.where(repo: repo_path, application_id: application_id)
        if existing_apps.length == 1
          existing_apps[0]
        else
          if existing_apps.empty?
            flash[:alert] = format("Failed to find application using repo: %{repo_path} and application_id: %{application_id}",
                repo_path: repo_path, application_id: application_id)
          else
            flash[:alert] = "Found multiple applications using repo: %s and application_id: %" % [ repo_path, application_id]
          end

          render :new
        end
      end
    else
      Application.create!(name: app_name, repo: repo_path, domain: domain)
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

  def app_name
    repo_title = repo_path.split("/")[-1].tr("-", " ").humanize.titlecase
    repo_title.gsub(/\bApi\b/, "API")
  end

  def domain
    # Deployments created from push notifications will default to github.com
    "github.com"
  end

  def push_notification?
    params[:repo].present?
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
