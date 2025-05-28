class Application < ApplicationRecord
  extend FriendlyId

  friendly_id :fallback_shortname, use: :slugged, slug_column: :shortname

  validates :name, presence: { message: "is required" }

  validates :name, :status_notes, length: { maximum: 255 }

  validates :name, uniqueness: { case_sensitive: true }

  validates :default_branch, presence: true

  enum :default_branch, { master: "master", main: "main" }, prefix: true

  has_many :deployments, dependent: :destroy

  default_scope { order("name ASC") }

  ENVIRONMENTS_ORDER = %w[integration staging production].freeze

  def latest_deploys_by_environment
    @latest_deploys_by_environment ||= ENVIRONMENTS_ORDER
      .index_with { |environment| deployments.last_deploy_to(environment) }
      .compact
  end

  def current_image_deployed_by_environment(repo_name:)
    @current_image_deployed_by_environment ||= ENVIRONMENTS_ORDER
      .index_with { |environment| ClusterState.get_image_tag(repo_name: repo_name, environment: environment) }
      .compact
  end

  def in_sync?(environments)
    latest_deploys_by_environment
      .slice(*environments)
      .values
      .map(&:version)
      .uniq
      .length <= 1
  end

  def status
    envs = %w[production staging integration]

    return :production_and_staging_not_in_sync unless in_sync?(envs.take(2))
    return :undeployed_changes_in_integration unless in_sync?(envs)

    :all_environments_match
  end

  # def name
  #   Repo.shortname(app_name: name)
  # end

  def fallback_shortname
    Repo.shortname(app_name: name).nil? ? name.parameterize : Repo.shortname(app_name: name)
  end

  def repo_path
    "alphagov/#{name.parameterize}"
  end

  def repo_url
    Repo.url(app_name: name).nil? ? "https://github.com/#{repo_path}" : Repo.url(app_name: name)
  end

  def repo_compare_url(from, to)
    "#{repo_url}/compare/#{from}...#{to}"
  end

  def self.cd_statuses
    @cd_statuses ||= YAML.safe_load(open("data/continuously_deployed_apps.yml"))
  end

  def self.out_of_sync
    all.reject do |app|
      app.status == :all_environments_match
    end
  end

  def github_data
    @github_data ||= begin
      response = Github.application(owner: "alphagov", name: name.parameterize)

      if response.errors.any?
        raise Github::QueryError, response.errors[:data].join(", ")
      else
        response.data
      end
    end
  end

  def cd_enabled?
    key = shortname || fallback_shortname
    Application.cd_statuses.include? key
  end

  def dependency_pull_requests_count
    github_data&.repository&.pull_requests&.total_count || 0
  end

  def commits
    @commits ||= github_data&.repository&.default_branch_ref&.target&.history&.edges&.map(&:node) || []
  end

  def commit_history
    commit_older_than_live_environment = false
    tags_by_commit = tag_names_by_commit

    commits.filter_map do |commit|
      unless commit_older_than_live_environment
        tags = tags_by_commit.fetch(commit.oid, [])
        deployed_to = []

        latest_deploys_by_environment.each do |environment, deployment|
          if tags.include?(deployment.version) || deployment.commit_match?(commit.oid)
            commit_older_than_live_environment = true if environment == live_environment
            deployed_to << deployment
          end
        end

        {
          deployed_to:,
          tags:,
          message: commit.message.split("\n")[0],
          author: commit.author.name,
          sha: commit.oid,
          github_url: "#{repo_url}/commit/#{commit.oid}",
        }
      end
    end
  end

  def environment_on_default_branch(environment)
    commit_history.any? do |commit|
      commit[:deployed_to].map(&:environment).include?(environment)
    end
  end

  def tag_names_by_commit
    tags = github_data&.repository&.refs&.edges || []

    tags.each_with_object({}) do |tag, hash|
      sha = tag.node.target.oid
      hash[sha] ||= []
      hash[sha] << tag.node.name
    end
  end

  def live_environment
    "production"
  end

  def team_name
    Repo.find_by(app_name: name)&.dig("alerts_team") || "#govuk-developers"
  end
end
