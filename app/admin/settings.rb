ActiveAdmin.register Settings do
  GENERAL_SETTINGS_COLUMNS = %w[payment_system address_geocoder before_create_trip_message validate_unpaid_trips].freeze
  FEATURE_SETTINGS_COLUMNS = %w[bonuses cashback delivery sos overspeed_notify].freeze

  menu false
  permit_params GENERAL_SETTINGS_COLUMNS + FEATURE_SETTINGS_COLUMNS
  actions :index, :show, :update, :edit

  show title: 'Settings' do |settings|
    tabs do
      tab "Features" do
        attributes_table do
          FEATURE_SETTINGS_COLUMNS.each { |title| row title }
        end
      end
      tab "General" do
        attributes_table do
          GENERAL_SETTINGS_COLUMNS.each { |title| row title }
        end
      end
    end
  end

  form do |f|
    tabs do
      tab 'Features' do
        f.inputs do
          FEATURE_SETTINGS_COLUMNS.each { |title| input title }
        end
      end
      tab 'General' do
        f.inputs do
          GENERAL_SETTINGS_COLUMNS.each { |title| input title }
        end
      end
    end
    f.actions
  end
end
