class Release < ActiveRecord::Base
  attr_accessible :notes, :summary, :product_team_members, :additional_support_notes,
    :deploy_at, :tasks_attributes

  has_many :tasks
  has_many :applications, through: :tasks

  accepts_nested_attributes_for :tasks

  default_scope order("deploy_at ASC")

  scope :previous_releases, lambda { where("deploy_at < ?", Date.today.beginning_of_day) }
  scope :todays_releases, lambda { where("deploy_at >= ? and deploy_at <= ?", Date.today.beginning_of_day, Date.today.end_of_day) }
  scope :future_releases, lambda { where("deploy_at > ?", Date.today.end_of_day) }

  validate :validate_tasks

  def unique_applications
    applications.uniq
  end

  private

  def validate_tasks
    errors.add(:tasks, "requires at least one task") if tasks.length < 1
  end
end
