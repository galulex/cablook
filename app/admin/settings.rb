ActiveAdmin.register Settings do
  menu false
  permit_params Constants::Admin::GENERAL_SETTINGS_COLUMNS
  actions :index, :show, :update, :edit

  member_action :switch, method: :post do
    feature = params[:feature]
    Settings.send(feature) ? Settings.disable(feature) : Settings.enable(feature)
    redirect_to admin_setting_path
  end

  show title: Constants::Admin::SETTINGS_TITLE do |_settings|
    tabs do
      tab Constants::Admin::FEATURES_TITLE do
        render 'show'
      end
      tab Constants::Admin::GENERAL_TITLE do
        attributes_table { Constants::Admin::GENERAL_SETTINGS_COLUMNS.each { |title| row title } }
      end
    end
  end

  form do |f|
    f.inputs { Constants::Admin::GENERAL_SETTINGS_COLUMNS.each { |title| input title } }
    f.actions
  end
end
