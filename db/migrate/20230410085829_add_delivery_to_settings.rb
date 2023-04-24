class AddDeliveryToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :delivery, :boolean, default: :false
  end
end
