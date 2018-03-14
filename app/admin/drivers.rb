ActiveAdmin.register Driver do
  controller do
    def permitted_params
      params.permit!
    end
  end

  index do
    selectable_column
    (driver_columns - %w[encrypted_password]).each { |title| column title }
    actions
  end

  show do
    attributes_table do
      driver_columns.each { |title| row title }
    end
  end

  form do |f|
    semantic_errors
    inputs ' Driver Details' do
      driver_columns.each { |title| input title }
    end
    actions
  end

  remove_filter :encrypted_password, :auth_token
end

def driver_columns
  columns_exclude = %w[auth_token car_id]
  added_columns = %w[car]
  Driver.column_names - columns_exclude + added_columns
end
