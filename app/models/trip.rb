class Trip < ApplicationRecord
  belongs_to :driver, required: false
  belongs_to :car, required: false
  belongs_to :user, counter_cache: true
  has_many :payments
  has_one :order
  has_one :tip_payment, class_name: 'Payments::Tip'
  has_one :trip_payment, class_name: 'Payments::Trip'
  has_one :idle_payment, class_name: 'Payments::Idle'
  has_one :order_payment, class_name: 'Payments::Order'
  has_one :fake_taxi_payment, class_name: 'Payments::FakeTaxi'
  has_many :required_payments, -> { where.not(type: 'Payments::Tip') }, class_name: 'Payment'

  has_one :card, through: :payments
  has_many :feedbacks
  has_one :bonus_trip, dependent: :destroy
  has_one :telegram, through: :user

  enum status: Constants::Trip::STATUS_CODES.invert

  delegate :phone_number, to: :user, prefix: true

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

  scope :statistics, (lambda do
    where(status: Constants::Trip::FINISHED)
      .left_joins(:tip_payment, :feedbacks, :required_payments)
      .select('COUNT(trips.id) AS trips_count, SUM(COALESCE(required_payments_trips.amount, 0)) AS amount')
      .select('SUM(COALESCE(trips.distance, 0)) AS distance')
      .select('SUM(COALESCE(payments.amount, 0)) AS tips')
      .select('ROUND(COALESCE(AVG(feedbacks.rate), 0), 1) AS rate')
      .group(:user_id)
      .order(:user_id)
  end)

  scope :this_month, -> { where('created_at BETWEEN ? AND ?', Date.current.beginning_of_month, Date.current.end_of_month) }
  scope :last_week, ->  { where('created_at BETWEEN ? AND ?', Date.current.beginning_of_week, Date.current.end_of_week) }
  scope :last_month, -> { where('created_at BETWEEN ? AND ?', 1.month.ago.to_date.beginning_of_month, 1.month.ago.to_date.end_of_month) }

  # Time for pre-order trip
  attr_reader :time, :entrance, :vip
  attr_writer :pre_order, :vip
  attr_accessor :osrm, :formatted_date, :image

  scope :sum_cost, (lambda do
    joins(:driver)
      .joins("LEFT JOIN payments ON trips.id = payments.trip_id AND payments.type = 'Payments::Tip'")
      .select('COUNT(trips.id) AS trips_count, SUM(trips.cost) AS trips_sum, MIN(drivers.username) AS username')
      .select('SUM(payments.amount) AS tips_sum')
      .group(:driver_id)
      .order(:driver_id)
  end)
  scope :beetwen, ->(from, to) { where('created_at BETWEEN ? AND ?', from, to) }
  scope :by_status, ->(status) { where(status: status) }
  scope :unpaid, -> { joins(:trip_payment).where('payments.status = ? AND trips.status = ?', Constants::Payments::PENDING, Constants::Trip::FINISHED) }

  def start_at
    super || preorder_time
  end

  def entrance=(val)
    return if val.blank?
    self[:comment] = "#{comment} #{I18n.t('trips.entrance', val: val)}"
  end

  def preorder?
    preorder_time.present?
  end

  def vip
    return true if order.present?
    user&.vip || false
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

  def image
    @image ||= "https://api.mapbox.com/styles/v1/mapbox/streets-v10/static/pin-s-s+188753(#{departure.reverse.join(',')}),#{waypoints.map { |w| "pin-s-w+facc1f(#{w.split(',').reverse.join(',')})," }.join('')}pin-s-f+312d50(#{destination.reverse.join(',')}),path-5+188753-0.8(#{CGI.escape(path)})/auto/400x400?access_token=#{ENV['MAPBOX_KEY']}"
  end
end
