class Payment < ApplicationRecord
  include Periods

  PAYOUT_TYPE = "Payments::#{Constants::Payments::TYPES[:payout]}".freeze

  belongs_to :card, required: false
  belongs_to :trip, required: false
  belongs_to :order, required: false
  belongs_to :user, optional: true
  has_one :driver, through: :trip

  enum payment_method: Constants::Payments::PAYMENT_METHODS

  has_paper_trail

  delegate :pan, to: :card, prefix: true, allow_nil: true

  scope :pending, lambda {
    joins(:trip)
      .where(status: Constants::Payments::PENDING)
      .where(trips: { status: Constants::Trip::STATUS_CODES[Constants::Trip::FINISHED] })
  }

  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :payments, -> { where.not(type: PAYOUT_TYPE) }
  scope :payouts, -> { where(type: PAYOUT_TYPE) }

  scope :driver_statistics, (lambda do |driver_id|
    joins(:trip)
      .where(type: Constants::Payments::DRIVER_STATISTIC_ENTRIES, status: Constants::Payments::SUCCESS)
      .where(trips: { driver_id: driver_id })
      .select("payments.type as payments_type, COUNT(trips.id) as count,
               SUM(CASE WHEN payments.payment_method <> 2 THEN amount ELSE 0 END) as amount,
               SUM(CASE WHEN payments.payment_method = 2 THEN amount ELSE 0 END) as cash_amount")
      .group('payments.type')
  end)
end
