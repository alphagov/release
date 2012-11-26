class DeploysController < ApplicationController
  def index
    @deploys = Deploy.all
  end
end
