class AddOnAppStartMessageToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :on_app_start_message, :string, default: nil
  end
end
