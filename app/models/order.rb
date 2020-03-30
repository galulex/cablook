class Order < ApplicationRecord
  belongs_to :user
  belongs_to :vendor, counter_cache: true
  belongs_to :trip, optional: true
  has_one :payment, dependent: :nullify

  delegate :need_approve, to: :vendor, prefix: true
end
