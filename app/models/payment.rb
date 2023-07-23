class Payment < ApplicationRecord
  PAYOUT_TYPE = "Payments::#{Constants::Payments::TYPES[:payout]}".freeze

  belongs_to :card, required: false
  belongs_to :trip, required: false
  belongs_to :order, required: false
  belongs_to :user, optional: true
  has_one :driver, through: :trip

  has_paper_trail

  delegate :pan, to: :card, prefix: true, allow_nil: true

  scope :pending, -> {
    joins(:trip)
      .where(status: Constants::Payments::PENDING)
      .where(trips: { status: Constants::Trip::STATUS_CODES[Constants::Trip::FINISHED] })
  }

  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :payments, -> { where.not(type: PAYOUT_TYPE) }
  scope :payouts, -> { where(type: PAYOUT_TYPE) }
end
