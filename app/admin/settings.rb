ActiveAdmin.register Settings do
  SETTINGS_COLUMNS = %w[bonuses cashback].freeze

  menu false
  permit_params :bonuses, :cashback
  actions :index, :show, :update, :edit

  show title: 'Settings' do |settings|
    attributes_table do
      SETTINGS_COLUMNS.each { |title| row title }
    end
  end
end
