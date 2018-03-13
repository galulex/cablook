class User < ApplicationRecord
  has_many :trips
  has_many :cards

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
