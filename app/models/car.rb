class Car < ApplicationRecord
  has_one :driver
  has_many :trips

  enum status: Constants::Car::STATUS_CODES.invert

  validates :number, presence: true, uniqueness: true

  scope :for_map, -> { includes(:driver).where.not(status: Constants::Car::OFFLINE) }
  scope :for_broadcast, -> { where.not(status: Constants::Car::OFFLINE) }

  def display_name
    number
  end

  def location=(val)
    redis.set("position_#{id}", redis.get("car_#{id}"))
    redis.set("car_#{id}", val.join(','))
  end

  def location
    car_location = redis.get("car_#{id}")
    @location = car_location ? car_location&.split(',').map(&:to_f) : [0,0]
  end

  def position
    car_position = redis.get("position_#{id}")
    @position = car_position ? car_position&.split(',').map(&:to_f) : location
  end

  def speed
    redis_car_data['speed'] || 0
  end

  def current_trips
    redis_car_data['current_trips'] || []
  end

  private

  def redis_car_data
    return {} unless redis.get("car_data_#{id}")

    @redis_car_data ||= JSON.parse(redis.get("car_data_#{id}"))
  end

  def redis
    @redis ||= Redis.new
  end
end
