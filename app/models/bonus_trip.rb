class BonusTrip < ApplicationRecord
  self.inheritance_column = :_type_disabled

  enum status: Constants::BonusTrip::STATUSES.invert

  belongs_to :user
  belongs_to :friend, class_name: 'User', foreign_key: 'friend_id', optional: true
  belongs_to :trip, required: false
end
