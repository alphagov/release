class Deployment < ApplicationRecord
  belongs_to :application

  validates :version, :environment, :application_id, presence: true

  scope :newest_first, -> { order("created_at DESC") }

  def self.last_deploy_to(environment)
    where(environment:)
      .order("created_at DESC")
      .first
  end

  def previous_deployment
    @previous_deployment ||= Deployment
      .where(application_id:, environment:)
      .where("id < ?", id)
      .order("id DESC")
      .first
  end

  def previous_version
    previous_deployment.try(:version)
  end

  def commits
    @commits ||=
      begin
        Services.github.compare(application.repo_path, previous_version, version).commits.reverse.map do |commit|
          Commit.new(commit.to_h, application)
        end
      rescue Octokit::NotFound
        []
      end
  end

  def diff_url
    application.repo_compare_url(previous_version, version)
  end

  def commit_match?(sha)
    commit_sha = commits.first&.sha || ""
    return false if commit_sha.length < 6

    sha.starts_with?(commit_sha)
  end

  def to_live_environment?
    environment == application.live_environment
  end

  def can_mark_as_change_failure?
    application.enable_change_failure_marking? && environment == "production"
  end
end
