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
    redis.set("position_#{car_id}", redis.get("car_#{car_id}"))
    redis.set("car_#{car_id}", location.join(','))
  end

  def location
    @location = Redis.current.get("car_#{id}")&.split(',').map(&:to_f)
  end

  def position
    @position = Redis.current.get("position_#{id}")&.split(',').map(&:to_f)
  end

  private

  def redis
    @redis ||= Redis.current
  end
end
