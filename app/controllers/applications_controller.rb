class ApplicationsController < ApplicationController
  before_action :find_application, only: %i[show edit update deploy stats]

  include ActionView::Helpers::DateHelper

  ENVIRONMENTS = %w[production staging integration].freeze

  def index
    @applications = Application.where(archived: false)
    @environments = ENVIRONMENTS
  end

  def archived
    @applications = Application.where(archived: true)
    @environments = ENVIRONMENTS
  end

  def stats
    @stats = DeploymentStats.new(Deployment.where(application_id: @application.id))
  end

  def show
    respond_to do |format|
      format.json { render json: @application }
      format.html do
        @outstanding_dependency_pull_requests = Services.github.search_issues("repo:#{@application.repo} is:pr state:open label:dependencies")[:total_count]

        @tags_by_commit = Services.github.tags(@application.repo).each_with_object({}) do |tag, hash|
          sha = tag[:commit][:sha]
          hash[sha] ||= []
          hash[sha] << tag
        end
        # where version == git tag, which it isn't for licensify
        @latest_deploy_to_each_environment_by_version = {}
        @application.latest_deploy_to_each_environment.each_value do |deployment|
          @latest_deploy_to_each_environment_by_version[deployment.version] ||= []
          @latest_deploy_to_each_environment_by_version[deployment.version] << deployment
        end

        @production_deploy = @application.deployments.last_deploy_to production_environment_name
        if @production_deploy
          comparison = Services.github.compare(
            @application.repo,
            @production_deploy.version,
            @application.default_branch,
          )
          # The `compare` API shows commits in forward chronological order
          @commits = comparison.commits.reverse + [comparison.base_commit]
        else
          # the `commits` API shows commits in reverse chronological order
          @commits = Services.github.commits(@application.repo)
        end

        @github_available = true
      rescue Octokit::TooManyRequests
        @github_available = false
        @github_error = github_rate_limited_error_message
      rescue Octokit::NotFound => e
        @github_available = false
        @github_error = e.message
      rescue Octokit::Error => e
        GovukError.notify(e.message)
        @github_available = false
        @github_error = e.message
      end
    end
  end

  def new
    @application = Application.new
  end

  def edit; end

  def deploy
    @release_tag = params[:tag]

    @production_deploy = @application.deployments.last_deploy_to production_environment_name

    if @production_deploy
      comparison = Services.github.compare(
        @application.repo,
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

  def github_rate_limited_error_message
    message = "Github API rate limit exceeded. "
    resets_at = Services.github.rate_limit.try(:resets_at)
    if resets_at
      time_until_reset = time_ago_in_words(resets_at)
      message << "Rate limit will reset in #{time_until_reset}."
    end
    message
  end

  def find_application
    @application = Application.friendly.find(params[:id])
  end

  def application_params
    params.require(:application).permit(
      :archived,
      :id,
      :name,
      :repo,
      :default_branch,
      :shortname,
      :status_notes,
      :task,
      :on_aws,
      :deploy_freeze,
    )
  end

  def production_environment_name
    if @application.on_aws?
      "production-aws"
    else
      "production"
    end
  end
end
