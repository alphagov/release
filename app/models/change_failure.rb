class ChangeFailure < ApplicationRecord
  belongs_to :deployment

  validates :description, length: { maximum: 255 }
end
