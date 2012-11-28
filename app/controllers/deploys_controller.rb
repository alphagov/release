class DeploysController < ApplicationController
  def index
    @deploys = Deploy.all
  end

  def show
    @deploy = Deploy.find(params[:id])
  end

  def new
    application = Application.find(params[:application_id])
    @deploy = application.deploys.build
  end

  def edit
    @deploy = Deploy.find(params[:id])
  end

  def create
    return error_404 if params[:application_id].nil?

    application = Application.find(params[:application_id])
    @deploy = application.deploys.build(params[:deploy])

    if @deploy.valid? && @deploy.save
      redirect_to @deploy, flash: { notice: "Successfully created new deploy task" }
    else
      render action: "new", flash: { alert: "There are some problems with the deploy task" }
    end
  end

  def update
    @deploy = Deploy.find(params[:id])

    if @deploy.update_attributes(params[:deploy])
      redirect_to @deploy, flash: { notice: "Successfully updated the deploy task" }
    else
      redirect_to @deploy, flash: { alert: "There are some problems with the deploy task" }
    end
  end
end
