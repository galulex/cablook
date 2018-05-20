class Business < ApplicationRecord
  belongs_to :owner, class_name: 'User', foreign_key: :user_id
  belongs_to :card
  has_and_belongs_to_many :users

  validates :name, :email, presence: true
  validates :email, format: { with: /@/ }

  before_destroy { users.clear }

  def employees=(numbers)
    ids = []
    numbers.map do |n|
      ids << User.where(phone_number: n).first_or_create do |u|
        u.auth_token = SecureRandom.base58(24)
        u.referral_code = SecureRandom.base58(6)
      end.id
      self.user_ids = ids
    end
  end
end
