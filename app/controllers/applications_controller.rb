require "github"

class ApplicationsController < ApplicationController
  before_filter :find_application, only: [:show, :edit, :update]
  def index
    @environments = ["staging", "production"]
    @applications = Application.all
  end

  def show
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

  private
    def find_application
      @application = Application.find(params[:id])
    end
end
