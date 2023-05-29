class AddSosToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :sos, :boolean, default: true
  end
end
