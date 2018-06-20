class Payment < ApplicationRecord
  belongs_to :card, required: false
  belongs_to :trip
  belongs_to :user
  belongs_to :driver, required: false

  delegate :pan, to: :card, prefix: true, allow_nil: true
end
