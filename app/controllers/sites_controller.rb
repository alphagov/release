class SitesController < ApplicationController
  def show; end

  def update
    if site_settings.update(site_params)
      flash.now[:notice] = { message: "Site settings updated" }
    end

    render :show
  end

private

  def site_params
    params.require(:site).permit(:status_notes)
  end
end
