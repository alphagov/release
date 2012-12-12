class Application < ActiveRecord::Base
  attr_accessible :name, :repo

  validates_presence_of :name, message: 'is required'
  validates_presence_of :repo, message: 'is required'

  validates_uniqueness_of :name, :repo

  has_many :tasks, dependent: :destroy
  has_many :releases, through: :tasks

  default_scope order("name ASC")

  def tags
    github_client.tags(repo, "")
  end

  def github_client
    @github_client ||= Github.create_from_config(Rails.root.join("config", "github-credentials.yml"))
  end
end
