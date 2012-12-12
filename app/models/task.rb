class Task < ActiveRecord::Base
  attr_accessible :additional_support_required, :application_changes, :application_id,
                  :description, :extended_support_required, :notes, :version

  belongs_to :application
  belongs_to :release

  validates_presence_of :version, :application

  # default_scope order("created_at DESC")

  scope :recent_first, includes(:releases).order("releases.deploy_at DESC")

  def to_s
    "#{application.name} - #{version}"
  end
end
