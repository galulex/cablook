ActiveAdmin.register Settings do
  GENERAL_SETTINGS_COLUMNS = %w[payment_system address_geocoder before_create_trip_message].freeze
  SETTINGS_TITLE = 'Settings'.freeze
  FEATURES_TITLE = 'Features'.freeze
  GENERAL_TITLE = 'General'.freeze

  menu false
  permit_params GENERAL_SETTINGS_COLUMNS
  actions :index, :show, :update, :edit

  member_action :switch, method: :post do
    feature = params[:feature]
    Settings.send(feature) ? Settings.disable(feature) : Settings.enable(feature)
    redirect_to admin_setting_path
  end

  show title: SETTINGS_TITLE do |_settings|
    tabs do
      tab FEATURES_TITLE do
        render 'show'
      end
      tab GENERAL_TITLE do
        attributes_table { GENERAL_SETTINGS_COLUMNS.each { |title| row title } }
      end
    end
  end

  form do |f|
    f.inputs { GENERAL_SETTINGS_COLUMNS.each { |title| input title } }
    f.actions
  end
end
