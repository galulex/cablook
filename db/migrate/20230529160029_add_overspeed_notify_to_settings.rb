class AddOverspeedNotifyToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :overspeed_notify, :boolean, default: true
  end
end
