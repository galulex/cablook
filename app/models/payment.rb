class Payment < ApplicationRecord
  belongs_to :card
  belongs_to :trip
  belongs_to :user

  delegate :pan, to: :card, prefix: true, allow_nil: true
end
