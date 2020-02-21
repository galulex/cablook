ActiveAdmin.register Trip do
  preserve_default_filters!
  remove_filter :payments, :card, :path, :departure, :destination, :estimated_end_time, :start_at,
                :finish_at, :started_at, :finished_at, :arrived_at, :waypoints, :job, :bonus_trip, :feedbacks,
                :tip_payment, :trip_payment, :idle_payment, :required_payments, :fake_taxi_payment, :distance,
                :order, :order_payment, :telegram, :departure_address, :destination_address, :duration, :comment,
                :stops, :idle, :total, :no_call, :preorder_time
  filter :user, as: :select, collection: proc { User.joins(:trips).group(:id).all }
  filter :status, as: :select, collection: proc { Trip.statuses }

  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      super.includes(:trip_payment, :car, :user, :driver)
    end
  end

  index do
    selectable_column
    view_trip_columns(ordered_trip_columns, :column)
    actions
  end

  show do
    attributes_table do
      view_trip_columns(ordered_trip_columns + modified_columns, :row)
    end
    render 'custom_actions' unless trip.status == 'finished'
  end

  form do |f|
    semantic_errors
    inputs do
      %w[driver car status].each { |title| input title }
    end
    actions
  end

  member_action :finish, method: :put do
    trip_id = params[:id].to_i
    Events::Trips::Finish.(trip_id: trip_id)
    redirect_to admin_trip_path(trip_id), notice: 'Finished!'
  end

  member_action :accept, method: :put do
    car = Car.find(params[:car].to_i)
    trip_id = params[:id].to_i
    driver = car.driver
    Events::Trips::Accept.(trip_id: trip_id, driver_id: driver.id, car_id: car.id)
    redirect_to admin_trip_path(trip_id), notice: 'Accepted!'
  end
end

def ordered_trip_columns
  %w[id cost idle total departure_address destination_address stops status trip_payment
     car driver user created_at start_at finish_at started_at finished_at comment]
end

def view_trip_columns(columns, element)
  columns.each do |title|
    if modified_columns.include?(title)
      send(title, element)
    else
      send(element, title)
    end
  end
end

def modified_columns
  %w[duration path]
end

def path(element)
  send(element, 'path') do |trip|
    departure = trip.departure.reverse.join(',')
    destination = trip.destination.reverse.join(',')
    if trip.waypoints?
      waypoints = trip.waypoints.map{ |w| 'pin-s-w+facc1f(' + w.split(',').reverse.join(',') +'),' }.join('')
    end
    image_tag("https://api.mapbox.com/styles/v1/mapbox/streets-v10/static/pin-s-s+188753(#{departure}),#{waypoints}pin-s-f+312d50(#{destination}),path-5+188753-0.8(#{URI.encode(trip.path, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))})/auto/400x300?access_token=#{ENV["MAPBOX_KEY"]}")
  end
end

def duration(element)
  send(element, 'duration') do |trip|
    Time.at(trip.duration).utc.strftime('%H:%M:%S') if trip.duration
  end
end
