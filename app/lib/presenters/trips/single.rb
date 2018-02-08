class Presenters::Trips::Single < Presenters::BaseSingle
  properties :id, :status, :path, :cost, :departure, :destination,
             :departure_address, :destination_address,
             :start_at, :started_at, :finish_at, :finished_at, :duration, :distance,
             :user_id, :driver_id, :created_at

  collection :feedbacks, extend: Presenters::Feedbacks::Single, if: ->(options) { options[:user_options][:with_feedbacks] }
end
