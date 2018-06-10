class Tip < ApplicationRecord
  belongs_to :trip

  has_one :user, through: :trip
  has_one :driver, through: :trip
end
