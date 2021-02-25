class ApplicationSerializer < ActiveModel::Serializer
  attributes :name, :shortname, :archived, :deploy_freeze
  attribute :status_notes, key: :notes
  attribute :repo_url, key: :repository_url
  attribute :default_branch, key: :repository_default_branch
  attribute :on_aws, key: :hosted_on_aws
end
