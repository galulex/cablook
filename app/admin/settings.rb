ActiveAdmin.register Settings do
  SETTINGS_COLUMNS = %w[bonuses cashback delivery payment_system address_geocoder before_create_trip_message validate_unpaid_trips allowed_users].freeze

  menu false
  permit_params SETTINGS_COLUMNS
  actions :index, :show, :update, :edit

  show title: 'Settings' do |settings|
    attributes_table do
      SETTINGS_COLUMNS.each { |title| row title }
    end
  end
end
