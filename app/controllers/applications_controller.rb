class ApplicationsController < ApplicationController
  before_action :find_application, only: %i[show edit update deploy stats]

  include ActionView::Helpers::DateHelper

  ENVIRONMENTS = %w[production staging integration].freeze

  def index
    @applications = Application.all
    @environments = ENVIRONMENTS
  end

  def stats
    @stats = DeploymentStats.new(Deployment.where(application_id: @application.id))
  end

  def show
    respond_to do |format|
      format.json { render json: @application }
      format.html do
        @outstanding_dependency_pull_requests = @application.dependency_pull_requests_count
        @commits = @application.commit_history

        @github_available = true
      rescue Github::QueryError => e
        @github_available = false
        @github_error = e.message
        GovukError.notify(e.message)
      end
    end
  end

  def new
    @application = Application.new
  end

  def edit; end

  def deploy
    @release_tag = params[:tag]

    @production_deploy = @application.deployments.last_deploy_to(@application.live_environment)

    if @production_deploy
      comparison = Services.github.compare(
        @application.repo_path,
        @production_deploy.version,
        @release_tag,
      )
      # The `compare` API shows commits in forward chronological order
      @commits = comparison.commits.reverse.map { |commit_data| Commit.new(commit_data.to_h, @application) }
    end
    @github_available = true
  rescue Octokit::NotFound => e
    @github_available = false
    @github_error = e.message
  end

  def create
    @application = Application.new(application_params)

    if @application.save
      redirect_to @application, notice: "Successfully created new application"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @application.update(application_params)
      redirect_to @application, notice: "Successfully updated the application details"
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def find_application
    @application = Application.friendly.find(params[:id])
  end

  def application_params
    params.require(:application).permit(
      :id,
      :name,
      :default_branch,
      :status_notes,
      :task,
      :deploy_freeze,
    )
  end
end
