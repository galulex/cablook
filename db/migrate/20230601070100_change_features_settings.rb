class ChangeFeaturesSettings < ActiveRecord::Migration[5.2]
  def up
    remove_column :settings, :overspeed_notify
    remove_column :settings, :sos
    remove_column :settings, :validate_unpaid_trips
    remove_column :settings, :delivery
    remove_column :settings, :bonuses
    remove_column :settings, :cashback
    add_column :settings, :disabled_features, :text, array: true, default: []
  end

  def down
    add_column :settings, :overspeed_notify, :boolean, default: :true
    add_column :settings, :sos, :boolean, default: :true
    add_column :settings, :validate_unpaid_trips, :boolean, default: :true
    add_column :settings, :delivery, :boolean, default: :false
    add_column :settings, :bonuses, :boolean, default: :false
    add_column :settings, :cashback, :boolean, default: :false
    remove_column :settings, :disabled_features
  end
end
