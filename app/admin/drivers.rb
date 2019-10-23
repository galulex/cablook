ActiveAdmin.register Driver do
  DRIVER_COLUMNS = %w[name username password address car].freeze
  preserve_default_filters!
  remove_filter :car, :trips, :address, :address_location

  controller do
    def permitted_params
      params.permit!
    end
  end

  index do
    selectable_column
    DRIVER_COLUMNS.each { |title| column title }
    actions
  end

  show do
    attributes_table do
      DRIVER_COLUMNS.each { |title| row title }
    end
  end

  form do |f|
    semantic_errors
    inputs do
      DRIVER_COLUMNS.each { |title| input title }
    end
    actions
  end

  remove_filter :encrypted_password, :auth_token
end
