class Presenters::Trips::Single < Presenters::BaseSingle
  properties :id, :path, :cost, :departure, :destination,
             :departure_address, :destination_address, :waypoints,
             :start_at, :started_at, :finish_at, :finished_at, :duration, :distance, :comment,
             :user_id, :driver_id, :created_at, :stops, :time, :no_call, :pre_order

  property :status, exec_context: :decorator

  collection :feedbacks, extend: Presenters::Feedbacks::Single, if: ->(options) { options[:user_options][:with_feedbacks] }

  def status
    Trip.statuses[represented.status]
  end
end
