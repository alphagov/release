class Api::ApplicationsController < Api::ApplicationController
  def show
    @application = Application.friendly.find(params[:id])

    render json: @application
  end
end
