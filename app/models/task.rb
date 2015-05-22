class Task < ActiveRecord::Base
  belongs_to :application
  belongs_to :release

  validates :application, :description, presence: true

  # default_scope { order("created_at DESC") }

  scope :recent_first, lambda { includes(:release).order("releases.deploy_at DESC") }

  def to_s
    "#{application.name} - #{version}"
  end
end
