class Presenters::Trips::DetailedDeliveryTrip < Presenters::BaseSingle
  properties :id, :status, :destination_address

  property :finish_time, exec_context: :decorator
  property :delivery_items, exec_context: :decorator

  # TAKE A LOOK. I'm not sure this is the right time delivery time. So I leave the delivery time from local storage for now (current_delivery_trip.js:15)
  def finish_time
    (represented.start_at + represented.duration.seconds).strftime('%H:%M')
  rescue
    nil
  end

  def delivery_items
    represented.order.items.values.map { |i| i.gsub(/=>/, ':') }
  rescue
    nil
  end
end
