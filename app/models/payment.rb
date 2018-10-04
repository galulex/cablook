class Payment < ApplicationRecord
  belongs_to :card, required: false
  belongs_to :trip
  belongs_to :user
  has_one :driver, through: :trip

  delegate :pan, to: :card, prefix: true, allow_nil: true

  scope :pending, ->(user_id) { where(status: Constants::Payments::PENDING, user_id: user_id).joins(:trip).where(trips: { status: Constants::Trip::STATUS_CODES[Constants::Trip::FINISHED] }) }
end
