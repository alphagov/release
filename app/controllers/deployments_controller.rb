class DeploymentsController < ApplicationController
  def new
    default_deploy_time = Time.now.strftime("%e/%m/%Y %H:%M")
    @deployment = Deployment.new(application_id: params[:application_id], environment: params[:environment], created_at: default_deploy_time)
  end

  def create
    if push_notification?
      Deployment.create!(params[:deployment].merge(application: application))
      head 200
    else
      @deployment = Deployment.new(params[:deployment])
      if @deployment.save
        application = Application.find(params[:deployment][:application_id])
        redirect_to applications_path, notice: "Deployment created for #{application.name}"
      else
        flash[:alert] = "Failed to create deployment"
        render :new
      end
    end
  end

  private
    def application
      if existing_app = Application.find_by_repo(repo_path)
        existing_app
      else
        Application.create!(name: app_name, repo: repo_path)
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
      repo_path.split("/")[-1].gsub("-", " ").humanize.titlecase
    end

    def push_notification?
      params[:repo].present?
    end
end