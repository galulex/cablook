class Order < ApplicationRecord
  belongs_to :user
  belongs_to :vendor
  belongs_to :trip, optional: true
  has_one :payment
end
