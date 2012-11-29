class ReleasesController < ApplicationController
  def index
    @releases = Release.all
  end

  def show
    @release = Release.find(params[:id])
  end

  def new
    @release = Release.new
  end

  def edit
    @release = Release.find(params[:id])
  end

  def create
    @release = Release.new(params[:release])

    if @release.valid? && @release.save
      redirect_to @release, flash: { notice: "Successfully created new release" }
    else
      render action: "new", flash: { alert: "There are some problems with the release" }
    end
  end

  def update
    @release = Release.find(params[:id])

    if @release.update_attributes(params[:release])
      redirect_to @release, flash: { notice: "Successfully updated the release" }
    else
      redirect_to @release, flash: { alert: "There are some problems with the release" }
    end
  end
end
