ActiveAdmin.register Trip do
  index do
    selectable_column
    show_columns
    actions
  end
end

def show_columns
  columns_exclude = ['path']
  (Trip.column_names - columns_exclude).each do |title|
    column title
    path if title == 'destination_address'
  end
end

def path
  column 'path' do |trip|
    image_tag("https://maps.googleapis.com/maps/api/staticmap?size=350x300&path=enc:#{trip.path}&key=AIzaSyDlGdVGbkeO_30Yn7tPCpe61AgdrsXMbQ0")
  end
end

