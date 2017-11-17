class Site < ApplicationRecord
  validates :status_notes, length: { maximum: 255 }
  validate :there_can_be_only_one, on: :create

  def self.settings
    Site.first_or_initialize
  end

private

  def there_can_be_only_one
    errors.add(:base, 'There can only be one Site instance') if Site.count > 0
  end
end
