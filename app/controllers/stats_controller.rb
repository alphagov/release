class StatsController < ApplicationController
  def index
    @stats = DeploymentStats.new
  end
end
