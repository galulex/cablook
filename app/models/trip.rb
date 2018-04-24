class Trip < ApplicationRecord
  belongs_to :user
  belongs_to :driver
  belongs_to :car

  scope :sum_cost, -> do
     joins(:driver)
      .select('COUNT(trips.id) AS trips_count, SUM(trips.cost) AS trips_sum, MIN(drivers.username) AS username')
      .group(:driver_id)
      .order(:driver_id)
  end
  scope :beetwen, ->(from, to) { where('created_at BETWEEN ? AND ?', from, to) }
  scope :by_status, ->(status) { where(status: status) }
end
