class User < ApplicationRecord
  has_one :business, inverse_of: :owner
  has_many :devices
  has_one :telegram, class_name: 'UserTelegram'
  has_and_belongs_to_many :businesses
  has_many :trips
  has_many :cards
  has_many :orders
  has_many :bonus_trips
  has_one  :parent_bonus, foreign_key: 'friend_id', class_name: 'BonusTrip'
  has_many :business_cards, through: :businesses, source: :card
  has_many :favorite_addresses

  has_secure_token :auth_token

  before_create :generate_referral

  validates :phone_number, format: { with: Constants::Regex::PHONE_NUMBER }

  accepts_nested_attributes_for :telegram

  scope :for_verification, lambda { |phone, token|
    left_joins(:cards)
      .where(phone_number: phone, verification_token: token)
      .select('users.*')
      .select('MAX(cards.id) IS NOT NULL AS has_cards')
      .group(:id)
  }

  scope :fetch_user, ->(auth_token) {
    eager_load(:favorite_addresses, :bonus_trips, :parent_bonus).where(auth_token: auth_token)
  }

  def display_name
    phone_number
  end

  def self.from_telegram(number, username, chat_id)
    user = User.find_or_initialize_by(phone_number: "+#{sanitize_phone(number)}")
    user.update(telegram_attributes: { username: username, chat_id: chat_id })
  end

  def display_name
    phone_number
  end

  def enabled_notifications
    Constants::User::NOTIFICATIONS - notification_settings
  end

  def current_trip
    trip = trips.find_by(status: Constants::Trip::CURRENT_TRIP_STATUSES)
    Presenters::Trips::Detailed.new(trip).to_json if trip
  end

  private

  def generate_referral
    self.referral_code = SecureRandom.base58(6)
  end

  def self.sanitize_phone(number)
    number.tr('^0-9', '')
  end
end
