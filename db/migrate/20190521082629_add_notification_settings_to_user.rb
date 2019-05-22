class AddNotificationSettingsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :notification_settings, :string, array: true, default: []
  end
end
