class ApplicationsController < ApplicationController
  before_filter :find_application, only: [:show, :edit, :update, :update_notes]
  def index
    @environments = ["staging", "production"]
    @applications = Application.all
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
    @commits = github.commits(@application.repo)
    @github_available = true
  rescue Octokit::NotFound => e
    @github_available = false
    @github_error = e
  end

  def new
    @application = Application.new
  end

  def edit
  end

  def create
    @application = Application.new(params[:application])

    if @application.valid? && @application.save
      redirect_to @application, flash: { notice: "Successfully created new application" }
    else
      flash[:alert] = "There are some problems with the application"
      render action: "new"
    end
  end

  def update
    if @application.update_attributes(params[:application])
      redirect_to @application, flash: { notice: "Successfully updated the application" }
    else
      redirect_to edit_application_path(@application), flash: { alert: "There are some problems with the application" }
    end
  end

  def update_notes
    if @application.update_attributes(params[:application])
      redirect_to applications_path, flash: { notice: "Successfully updated notes" }
    else
      redirect_to applications_path, flash: { alert: "Failed to update notes" }
    end
  end

  private
    def find_application
      @application = Application.find(params[:id])
    end

    def github
      credentials = defined?(GITHUB_CREDENTIALS) ? GITHUB_CREDENTIALS : {}
      @client ||= Octokit::Client.new()
    end
end
