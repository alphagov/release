class ChangeFailuresController < ApplicationController
  before_action :find_deployment
  before_action :find_change_failure, only: %i[show edit update destroy]

  def new
    @change_failure = @deployment.build_change_failure
  end

  def show
  end

  def edit
  end

  def create
    @change_failure = @deployment.build_change_failure(change_failure_params)
    if @change_failure.save
      redirect_to deployment_change_failure_path(@deployment), notice: "Change failure was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @change_failure.update(change_failure_params)
      redirect_to deployment_change_failure_path(@deployment), notice: "Change failure was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @change_failure.destroy
    redirect_to deployment_path(@deployment), notice: "The change failure note for this deployment was successfully deleted."
  end

  private

  def find_deployment
    @deployment = Deployment.find(params[:deployment_id])
    error_404 unless @deployment.application.change_failure_tracking?
    error_404 unless @deployment.to_live_environment?
  end

  def change_failure_params
    params.require(:change_failure).permit(:description)
  end

  def find_change_failure
    @change_failure = @deployment.change_failure
  end
end
