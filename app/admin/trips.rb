ActiveAdmin.register Trip do
  index do
    selectable_column
    view_trip_columns(ordered_trip_columns - %w[departure destination], :column)
    actions
  end

  show do
    attributes_table do
      view_trip_columns(ordered_trip_columns, :row)
    end
  end
end

def ordered_trip_columns
  %w[id cost departure destination departure_address destination_address status
     path car driver user duration distance created_at start_at finish_at
     started_at finished_at arrived_at comment]
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
  %w[status path duration]
end

def status(element)
  send(element, 'status') do |trip|
    Constants::Trip::STATUS_CODES[trip.status]
  end
end

def path(element)
  send(element, 'path') do |trip|
    image_tag("https://maps.googleapis.com/maps/api/staticmap?size=350x300&path=enc:#{trip.path}&key=AIzaSyDlGdVGbkeO_30Yn7tPCpe61AgdrsXMbQ0")
  end
end

def duration(element)
  send(element, 'duration') do |trip|
    Time.at(trip.duration).utc.strftime('%H:%M:%S') if trip.duration
  end
end
