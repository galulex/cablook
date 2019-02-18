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
  delegate :vip, to: :user, allow_nil: true

  # Time for pre-order trip
  attr_reader :time, :entrance
  attr_writer :pre_order
  attr_accessor :osrm

  def start_at
    super || preorder_time
  end

  def entrance=(val)
    return if val.blank?
    self[:comment] = "#{comment} #{val} під'їзд"
  end

  def preorder?
    preorder_time.present?
  end

  def departure=(val)
    self[:departure] = val.split(',').flatten
  end

  def destination=(val)
    self[:destination] = val.split(',').flatten
  end

  alias pre_order preorder?

  def time=(val)
    return if val.blank?
    date = val.in_time_zone
    self.preorder_time = Time.now.in_time_zone < date ? date : (date + 1.day)
    @time = val
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
