class AddTypeToBonusTrips < ActiveRecord::Migration[5.1]
  def change
    add_column :bonus_trips, :type, :string
  end
end
