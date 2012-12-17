class DeploymentsController < ApplicationController
  def create
    Deployment.create!(params[:deployment].merge(application: application))
    head 200
  end

  private
    def application
      if existing_app = Application.find_by_repo(repo_path)
        existing_app
      else
        Application.create!(name: repo_path.split("/")[-1], repo: repo_path)
      end
    end

    def repo_path
      if params[:repo].start_with?("http")
        URI.parse(params[:repo]).path.gsub(%r{^/}, "")
      else
        params[:repo]
      end
    end
end