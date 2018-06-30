class Car < ApplicationRecord
  has_one :driver

  enum status: Constants::Car::STATUS_CODES.invert

  validates :number, presence: true, uniqueness: true

  scope :for_map, -> { includes(:driver).where.not(status: Constants::Car::OFFLINE) }

  def display_name
    number
  end

  def location
    @location ||= Redis.current.get("car_#{id}")&.split(',')
  end
end
