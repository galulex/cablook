class User < ApplicationRecord
  has_one :business, inverse_of: :owner
  has_one :device
  has_and_belongs_to_many :businesses
  has_many :trips
  has_many :cards
  has_many :all_cards, ->(user) { user_cards(user.id) }, class_name: 'Card'
  has_many :bonus_trips
  has_many :business_cards, through: :businesses, source: :card
  has_many :favorite_addresses

  validates :phone_number, format: { with: Constants::Regex::PHONE_NUMBER }

  scope :for_verification, lambda { |phone, token|
    left_joins(:cards)
      .where(phone_number: phone, verification_token: token)
      .select('users.*')
      .select('MAX(cards.id) IS NOT NULL AS has_cards')
      .group(:id)
  }

  scope :fetch_user, ->(auth_token) {
    eager_load(:favorite_addresses, :bonus_trips).where(auth_token: auth_token)
    .as_json(only: %i(email phone), include: [all_cards: {except: :token}, favorite_addresses: {}, bonus_trips: {}])
  }

  def display_name
    phone_number
  end

end
