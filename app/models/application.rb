class Application < ApplicationRecord
  extend FriendlyId

  friendly_id :fallback_shortname, use: :slugged, slug_column: :shortname

  validates :name, presence: { message: "is required" }

  validates :name, :status_notes, length: { maximum: 255 }

  validates :name, uniqueness: { case_sensitive: true }

  validates :default_branch, presence: true

  enum default_branch: { master: "master", main: "main" }, _prefix: true

  has_many :deployments, dependent: :destroy

  default_scope { order("name ASC") }

  ENVIRONMENTS_ORDER = %w[integration staging production].freeze

  def latest_deploys_by_environment
    @latest_deploys_by_environment ||= ENVIRONMENTS_ORDER
      .index_with { |environment| deployments.last_deploy_to(environment) }
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

  def cd_enabled?
    key = shortname || fallback_shortname
    Application.cd_statuses.include? key
  end

  def dependency_pull_requests
    Services.github.search_issues("repo:#{repo_path} is:pr state:open label:dependencies")
  end

  def commits
    @commits ||= Services.github.commits(repo_path, { per_page: 50 })
  end

  def commit_history
    commit_older_than_live_environment = false
    tags_by_commit = tag_names_by_commit

    commits.filter_map do |commit|
      unless commit_older_than_live_environment
        tags = tags_by_commit.fetch(commit[:sha], [])
        deployed_to = []

        latest_deploys_by_environment.each do |environment, deployment|
          if tags.include?(deployment.version) || deployment.commit_match?(commit[:sha])
            commit_older_than_live_environment = true if environment == live_environment
            deployed_to << deployment
          end
        end

        {
          deployed_to:,
          tags:,
          message: commit[:commit][:message].split(/\n/)[0],
          author: commit.dig(:commit, :author, :name),
          sha: commit[:sha],
          github_url: "#{repo_url}/commit/#{commit[:sha]}",
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
    tags = Services.github.tags(repo_path)

    tags.each_with_object({}) do |tag, hash|
      sha = tag[:commit][:sha]
      hash[sha] ||= []
      hash[sha] << tag[:name]
    end
  end

  def live_environment
    "production"
  end

  def team_name
    Repo.find_by(app_name: name)&.dig("team") || "#govuk-developers"
  end
end
