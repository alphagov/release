require "github"

class ApplicationsController < ApplicationController
  def index
    @applications = Application.all
  end

  def show
    @application = Application.find(params[:id])
  end

  def new
    @application = Application.new
  end

  def edit
    @application = Application.find(params[:id])
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
    @application = Application.find(params[:id])

    if @application.update_attributes(params[:application])
      redirect_to @application, flash: { notice: "Successfully updated the application" }
    else
      redirect_to @application, flash: { alert: "There are some problems with the application" }
    end
  end

  def tags
    @application = Application.find(params[:id])

    client = Github.create_from_config(Rails.root.join("config", "github-credentials.yml"))

    render json: client.tags(@application.repo, params[:term] || "")
  end
end
