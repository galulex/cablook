class Card < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :user

  scope :user_cards, (lambda do |user|
    select('cards.*')
      .select("CASE WHEN cards.user_id = #{user} THEN 0 ELSE 1 END AS property")
      .joins('LEFT JOIN businesses ON businesses.card_id = cards.id')
      .joins('LEFT JOIN businesses_users ON businesses.id = businesses_users.business_id')
      .where('businesses_users.user_id = :user OR cards.user_id = :user', user: user)
      .group('cards.id')
      .order('property ASC, id DESC')
  end)
end
