class ApplicationsController < ApplicationController
  def index
    @applications = Application.all
  end
end
