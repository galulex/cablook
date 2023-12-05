class Trip < ApplicationRecord
  include Periods

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
  has_many :required_payments, -> { where.not(type: Constants::Payments::OPTIONAL_PAYMENTS) }, class_name: 'Payment'

  has_one :card, through: :payments
  has_many :feedbacks
  has_one :bonus_trip, dependent: :destroy
  has_one :telegram, through: :user

  has_paper_trail

  enum status: Constants::Trip::STATUS_CODES.invert

  delegate :phone_number, to: :user, prefix: true

  before_validation :set_comment

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

  # Time for pre-order trip
  attr_accessor :vip
  attr_reader :time
  attr_writer :pre_order
  attr_accessor :osrm, :formatted_date, :entrance, :image

  scope :sum_cost, (lambda do
    joins(:driver)
      .joins('LEFT JOIN payments ON trips.id = payments.trip_id')
      .select("COUNT(trips.id) AS trips_count, MIN(drivers.username) AS username,
               SUM(CASE WHEN payments.payment_method <> 2 THEN payments.amount ELSE 0 END) AS trips_sum,
               SUM(CASE WHEN payments.payment_method = 2 THEN payments.amount ELSE 0 END) AS cash_sum,
               SUM(CASE WHEN payments.type = 'Payments::Tip' THEN payments.amount ELSE 0 END) AS tips_sum")
      .group(:driver_id)
      .order(:driver_id)
  end)
  scope :beetwen, ->(from, to) { where('created_at BETWEEN ? AND ?', from, to) }
  scope :by_status, ->(status) { where(status: status) }
  scope :unpaid, -> { joins(:trip_payment).where('payments.status = ? AND trips.status = ?', Constants::Payments::PENDING, Constants::Trip::FINISHED) }
  scope :unfinished, -> { where(status: [Constants::Trip::ON_THE_WAY, Constants::Trip::WAITING_CLIENT, Constants::Trip::DRIVING]) }
  scope :current, -> { unfinished.order(:start_at) }
  scope :for_driver, ->(driver) { unfinished.where(driver: driver).or(Trip.pending).order(:start_at, :preorder_time) }

  def start_at
    super || preorder_time
  end

  # def entrance=(val)
  #   binding.pry
  #   return if val.blank?
  #   self[:comment] = "#{comment} #{I18n.t('trips.entrance', val: val)}"
  # end

  def preorder?
    preorder_time.present?
  end

  def current?
    on_the_way? || waiting_client? || driving?
  end

  def vip
    return true if trip_payment&.card&.business.present?

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

  def set_comment
    entr = entrance.blank? ? nil : I18n.t('trips.entrance', val: entrance)
    self[:comment] = "#{comment} #{entr}"
  end
end
