class Trip < ApplicationRecord
  belongs_to :driver, required: false
  belongs_to :car, required: false
  belongs_to :user, counter_cache: true
  has_many :payments
  has_one :tip_payment, class_name: 'Payments::Tip'
  has_one :trip_payment, class_name: 'Payments::Trip'
  has_one :idle_payment, class_name: 'Payments::Idle'
  has_one :fake_taxi_payment, class_name: 'Payments::FakeTaxi'

  has_one :card, through: :payments
  has_many :feedbacks
  has_one :job, dependent: :destroy, class_name: 'TripJob'
  has_one :bonus_trip, dependent: :destroy

  enum status: Constants::Trip::STATUS_CODES.invert

  delegate :phone_number, to: :user, prefix: true

  # Time for pre-order trip
  attr_reader :time

  def preorder?
    status == Constants::Trip::STATUS_CODES[Constants::Trip::PRE_ORDERED]
  end

  def time=(val)
    date = val.to_time.in_time_zone
    self.start_at = Time.now.in_time_zone < date ? date : (date + 1.day)
    @time = val
    self.status = Constants::Trip::STATUS_CODES[Constants::Trip::PRE_ORDERED]
  end

  scope :sum_cost, -> do
    joins(:driver)
      .joins("LEFT JOIN payments ON trips.id = payments.trip_id AND payments.type = 'Payments::Tip'")
      .select('COUNT(trips.id) AS trips_count, SUM(trips.cost) AS trips_sum, MIN(drivers.username) AS username')
      .select('SUM(payments.amount) AS tips_sum')
      .group(:driver_id)
      .order(:driver_id)
  end
  scope :beetwen, ->(from, to) { where('created_at BETWEEN ? AND ?', from, to) }
  scope :by_status, ->(status) { where(status: status) }
  scope :unpaid, -> { joins(:trip_payment).where('payments.status = ? AND trips.status = ?', Constants::Payments::PENDING, Constants::Trip::FINISHED) }
end