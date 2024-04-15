class ApplicationSerializer < ActiveModel::Serializer
  attributes :name, :shortname, :deploy_freeze
  attribute :status_notes, key: :notes
  attribute :repo_url, key: :repository_url
  attribute :default_branch, key: :repository_default_branch
  attribute :cd_enabled?, key: :continuously_deployed
end
