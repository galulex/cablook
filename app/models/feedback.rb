class Feedback < ApplicationRecord
  belongs_to :trip
  belongs_to :user
  has_one :driver, through: :trip
end
