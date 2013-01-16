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
        Application.create!(name: app_name, repo: repo_path)
      end
    end

    def repo_path
      if params[:repo].start_with?("http")
        URI.parse(params[:repo]).path.gsub(%r{^/}, "")
      elsif params[:repo].start_with?("git@")
        params[:repo].split(":")[-1].gsub(/.git$/, "")
      else
        params[:repo]
      end
    end

    def app_name
      repo_path.split("/")[-1].gsub("-", " ").humanize.titlecase
    end
end