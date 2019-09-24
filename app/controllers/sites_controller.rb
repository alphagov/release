class SitesController < ApplicationController
  def show; end

  def update
    if site_settings.update(site_params)
      redirect_to root_path, alert: "Site settings updated"
    else
      render :show
    end
  end

private

  def site_params
    params.require(:site).permit(:status_notes)
  end
end
