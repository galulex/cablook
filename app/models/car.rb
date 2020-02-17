class Car < ApplicationRecord
  has_one :driver

  enum status: Constants::Car::STATUS_CODES.invert

  validates :number, presence: true, uniqueness: true

  scope :for_map, -> { includes(:driver).where.not(status: Constants::Car::OFFLINE) }

  attr_accessor :dis, :deg

  def display_name
    number
  end

  def location=(val)
    redis.set("position_#{id}", redis.get("car_#{id}"))
    redis.set("car_#{id}", val.join(','))
  end

  def location
    car_location = Redis.current.get("car_#{id}")
    @location = car_location ? car_location&.split(',').map(&:to_f) : [0,0]
  end

  def position
    car_position = Redis.current.get("position_#{id}")
    @position = car_position ? car_position&.split(',').map(&:to_f) : [0,0]
  end

  private

  def redis
    @redis ||= Redis.current
  end
end
