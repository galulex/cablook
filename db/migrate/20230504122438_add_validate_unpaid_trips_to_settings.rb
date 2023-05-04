class AddValidateUnpaidTripsToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :validate_unpaid_trips, :boolean, default: :true
  end
end
