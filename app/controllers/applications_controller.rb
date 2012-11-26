class ApplicationsController < ApplicationController
  def index
    @applications = Application.all
  end

  def new
    @application = Application.new
  end

  def create
    @application = Application.new(params[:application])

    if @application.save
      redirect_to @application
    else
      flash.now[:alert] = "There are some problems with the application"
      render action: "new"
    end
  end
end
