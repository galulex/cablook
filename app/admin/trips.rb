ActiveAdmin.register Trip do

  remove_filter :payments, :card, :path, :departure, :destination, :estimated_end_time, :start_at, :finish_at, :started_at, :finished_at, :arrived_at, :waypoints, :job, :bonus_trip, :feedbacks

  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      super.includes(:payments, :car, :user, :driver)
    end
  end

  index do
    selectable_column
    view_trip_columns(ordered_trip_columns, :column)
    actions do |trip|
      item 'Finish', finish_admin_trip_path(trip), method: :put, class: 'member_link' if trip.status == Constants::Trip::DRIVING
    end
  end

  show do
    attributes_table do
      view_trip_columns(ordered_trip_columns, :row)
    end
    render 'custom_actions' if trip.status == Constants::Trip::DRIVING
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
end

def ordered_trip_columns
  %w[id cost departure_address destination_address stops status payments
     car driver user duration distance created_at comment]
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
  %w[duration]
end

def path(element)
  send(element, 'path') do |trip|
    image_tag("https://maps.googleapis.com/maps/api/staticmap?size=400x300&path=enc:#{trip.path}&key=AIzaSyDlGdVGbkeO_30Yn7tPCpe61AgdrsXMbQ0")
  end
end

def duration(element)
  send(element, 'duration') do |trip|
    Time.at(trip.duration).utc.strftime('%H:%M:%S') if trip.duration
  end
end
