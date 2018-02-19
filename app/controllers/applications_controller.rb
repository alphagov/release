class ApplicationsController < ApplicationController
  before_action :redirect_if_read_only_user, only: [:new, :edit, :create, :update, :update_notes]
  before_action :find_application, only: [:show, :edit, :update, :update_notes, :deploy]

  include ActionView::Helpers::DateHelper

  def index
    @environments = %w(staging production)
    @applications = Application.where(archived: false)
  end

  def archived
    @environments = %w(staging production)
    @applications = Application.where(archived: true)
  end

  def show
    @tags_by_commit = github.tags(@application.repo).each_with_object({}) do |tag, hash|
      sha = tag[:commit][:sha];
      hash[sha] ||= [];
      hash[sha] << tag
    end
    # where version == git tag, which it isn't for licensify
    @latest_deploy_to_each_environment_by_version = {}
    @application.latest_deploy_to_each_environment.each do |_environment, deployment|
      @latest_deploy_to_each_environment_by_version[deployment.version] ||= []
      @latest_deploy_to_each_environment_by_version[deployment.version] << deployment
    end

    @production_deploy = @application.deployments.last_deploy_to "production"
    if @production_deploy
      comparison = github.compare(
        @application.repo,
        @production_deploy.version,
        "master"
      )
      # The `compare` API shows commits in forward chronological order
      @commits = comparison.commits.reverse + [comparison.base_commit]
    else
      # the `commits` API shows commits in reverse chronological order
      @commits = github.commits(@application.repo)
    end

    @github_available = true
    @latest_deployments = @application.deployments.newest_first.limit(25)
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

  def new
    @application = Application.new
  end

  def edit
  end

  def deploy
    @release_tag = params[:tag]

    if application_has_dashboard?(@application.shortname)
      @staging_dashboard_url = dashboard_url('grafana.staging.publishing.service.gov.uk', @application.shortname)
      @production_dashboard_url = dashboard_url('grafana.publishing.service.gov.uk', @application.shortname)
    end

    @production_deploy = @application.deployments.last_deploy_to "production"
    if @production_deploy
      comparison = github.compare(
        @application.repo,
        @production_deploy.version,
        @release_tag
      )
      # The `compare` API shows commits in forward chronological order
      @commits = comparison.commits.reverse
    end
    @github_available = true
  rescue Octokit::NotFound => e
    @github_available = false
    @github_error = e.message
  end

  def create
    @application = Application.new(application_params)

    if @application.valid? && @application.save
      redirect_to @application, flash: { notice: "Successfully created new application" }
    else
      flash.now[:error] = "There are some problems with the application"
      render action: "new"
    end
  end

  def update
    if @application.update_attributes(application_params)
      redirect_to @application, flash: { notice: "Successfully updated the application" }
    else
      flash.now[:error] = "There are some problems with the application"
      render :edit
    end
  end

  def update_notes
    if @application.update_attributes(application_notes_params)
      redirect_to applications_path, flash: { notice: "Successfully updated notes" }
    else
      redirect_to applications_path, flash: { error: "Failed to update notes" }
    end
  end

private

  def github_rate_limited_error_message
    message = "Github API rate limit exceeded. "
    resets_at = github.rate_limit.try(:resets_at)
    if resets_at
      time_until_reset = time_ago_in_words(resets_at)
      message << "Rate limit will reset in #{time_until_reset}."
    end
    message
  end

  def find_application
    @application = Application.friendly.find(params[:id])
  end

  def github
    credentials = defined?(GITHUB_CREDENTIALS) ? GITHUB_CREDENTIALS : {}
    @client ||= Octokit::Client.new(credentials)
  end

  def application_notes_params
    params.require(:application).permit(:status_notes)
  end

  def application_params
    params.require(:application).permit(
      :archived,
      :domain,
      :id,
      :name,
      :repo,
      :shortname,
      :status_notes,
      :task,
    )
  end

  def application_has_dashboard?(application_name)
    grafana_base_url = Plek.new.external_url_for('grafana')
    uri = URI("#{grafana_base_url}/api/dashboards/file/deployment_#{application_name}.json")
    request = Net::HTTP::Get.new(uri.path)

    begin
      grafana_api_response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http|
        http.read_timeout = 2 # seconds
        http.request(request)
      }
    rescue StandardError => e
      # Do not link to dashboards if Grafana API does not respond. Either
      # Grafana is not available or it does not exist in this environment (e.g.
      # development)
      logger.warn("Failed to call Grafana API at '#{uri}': #{e.message}")
      return false
    end

    grafana_api_response.is_a?(Net::HTTPSuccess)
  end

  def dashboard_url(host_name, application_name)
    "https://#{host_name}/dashboard/file/deployment_#{application_name}.json"
  end
end
