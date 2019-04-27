class Presenters::Trips::Single < Presenters::BaseSingle
  properties :id, :path, :cost, :departure, :destination,
             :departure_address, :destination_address, :waypoints,
             :start_at, :started_at, :finish_at, :finished_at, :duration, :distance, :comment,
             :user_id, :driver_id, :created_at, :stops, :time, :entrance, :no_call, :pre_order, :osrm, :vip

  property :bonus, exec_context: :decorator
  property :status, exec_context: :decorator
  property :formatted_date, exec_context: :decorator

  collection :feedbacks, extend: Presenters::Feedbacks::Single, if: ->(options) { options[:user_options][:with_feedbacks] }

  def bonus
    represented.bonus_trip.present?
  end

  def status
    Trip.statuses[represented.status]
  end

  def formatted_date
    represented.created_at.strftime('%d/%m/%Y, %H:%M')
  rescue
    nil
  end
end
