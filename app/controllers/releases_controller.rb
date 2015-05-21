class ReleasesController < ApplicationController
  before_filter :redirect_if_read_only_user, only: [:new, :edit, :create, :update]

  def index
    @releases = Release.all
    @todays_releases = Release.todays_releases.all
    @future_releases = Release.future_releases.all
  end

  def show
    @release = Release.find(params[:id])
  end

  def new
    @release = Release.new
  end

  def edit
    @release = Release.find(params[:id])
    @tasks = Task.where("release_id = ? OR release_id = ?", @release.id, nil)
  end

  def create
    @release = Release.new(release_params)

    if @release.valid? && @release.save_as(current_user)
      redirect_to @release, flash: { notice: "Successfully created new release" }
    else
      flash[:alert] = "There are some problems with the release"
      render action: "new"
    end
  end

  def update
    @release = Release.find(params[:id])

    if @release.update_attributes(release_params)
      redirect_to @release, flash: { notice: "Successfully updated the release" }
    else
      redirect_to @release, flash: { alert: "There are some problems with the release" }
    end
  end

  private
    def release_params
      params.require(:release).permit(
        :additional_support_notes,
        :deploy_at,
        :id,
        :notes,
        :product_team_members,
        :summary,
        tasks_attributes: [
          :additional_support_required,
          :application_changes,
          :application_id,
          :description,
          :extended_support_required,
          :version,
        ],
      )
    end
end
