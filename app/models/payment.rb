class Payment < ApplicationRecord
  belongs_to :card
  belongs_to :trip
  belongs_to :user
end
