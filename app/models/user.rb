class User < ApplicationRecord
  has_one :business, inverse_of: :owner
  has_and_belongs_to_many :businesses
  has_many :trips
  has_many :cards
  has_many :bonus_trips
  has_many :business_cards, through: :businesses, source: :card

  validates :phone_number, format: { with: Constants::Regex::PHONE_NUMBER }

  scope :for_verification, lambda { |phone, token|
    left_joins(:cards)
      .where(phone_number: phone, verification_token: token)
      .select('users.*')
      .select('MAX(cards.id) IS NOT NULL AS has_cards')
      .group(:id)
  }

  def display_name
    phone_number
  end
end
