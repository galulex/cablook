ActiveAdmin.register Car do
  controller do
    def permitted_params
      params.permit!
    end
  end

  index do
    selectable_column
    car_columns
    actions
  end
end

def car_columns
  columns_exclude = %w[status]
  (Car.column_names - columns_exclude).each do |title|
    column title
    car_status if title == 'number'
  end
end

def car_status
  column :status do |car|
    Constants::Car::STATUS_CODES[car.status]
  end
end
