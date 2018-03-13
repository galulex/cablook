ActiveAdmin.register Trip do
  index do
    selectable_column
    trip_columns
    actions
  end
end

def trip_columns
  columns_exclude = %w[departure destination car_id driver_id user_id] + modified_columns
  (Trip.column_names - columns_exclude).each do |title|
    column title
    modified_columns.map { |column| send(column) } if title == 'destination_address'
  end
end

def modified_columns
  %w[status path car driver user duration]
end

def status
  column 'status' do |trip|
    Constants::Trip::STATUS_CODES[trip.status]
  end
end

def path
  column 'path' do |trip|
    image_tag("https://maps.googleapis.com/maps/api/staticmap?size=350x300&path=enc:#{trip.path}&key=AIzaSyDlGdVGbkeO_30Yn7tPCpe61AgdrsXMbQ0")
  end
end

def car
  column 'car' do |trip|
    link_to trip.car.number, admin_car_path(trip.car) if trip.car
  end
end

def driver
  column 'driver' do |trip|
    link_to trip.driver.name, admin_driver_path(trip.driver) if trip.driver
  end
end

def user
  column 'user' do |trip|
    link_to trip.user.phone_number, admin_user_path(trip.user) if trip.user
  end
end

def duration
  column 'duration' do |trip|
    Time.at(trip.duration).utc.strftime('%H:%M:%S') if trip.duration
  end
end
