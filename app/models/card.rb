class Card < ApplicationRecord
  self.inheritance_column = :_type_disabled
  default_scope { order(default: :desc, id: :desc) }

  enum payment_system: Constants::Card::PAYMENT_SYSTEM

  belongs_to :user
  has_one :business
  has_many :payments, dependent: :nullify

  validates :token, :pan, :user_id, presence: true
  validates :token, uniqueness: { scope: :user_id }

  scope :user_cards, (lambda do |user|
    select('cards.*')
      .select("CASE WHEN cards.user_id = #{user} THEN 0 ELSE 1 END AS property")
      .joins('LEFT JOIN businesses ON businesses.card_id = cards.id')
      .joins('LEFT JOIN businesses_users ON businesses.id = businesses_users.business_id')
      .where('businesses_users.user_id = :user OR cards.user_id = :user', user: user)
      .where(payment_system: Settings.get.payment_system)
      .group('cards.id')
      .order('property ASC, id DESC')
  end)

  def as_json(*)
    super(except: :token)
  end
end
