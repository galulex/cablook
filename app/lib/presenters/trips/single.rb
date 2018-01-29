class Presenters::Trips::Single < Presenters::BaseSingle
  properties :id, :status, :path, :cost, :departure, :destination,
             :departure_address, :destination_address,
             :start_at, :started_at, :finish_at, :finished_at, :duration, :distance,
             :user_id, :driver_id, :created_at
end
