class Presenters::Trips::Single < Presenters::BaseSingle
  properties :id, :status, :path, :cost, :departure, :destination,
             :departure_address, :destination_address,
             :user_id, :driver_id, :created_at
end
