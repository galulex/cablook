class Feedback < ApplicationRecord
  include Periods

  belongs_to :trip
  belongs_to :user
  has_one :driver, through: :trip

  scope :avg_by_driver, ->(driver_id) {
    joins(:trip)
      .where(trips: { driver_id: driver_id })
      .select('ROUND(COALESCE(AVG(feedbacks.rate), 0), 1) AS rate')
      .group('trips.driver_id')
  }
end
