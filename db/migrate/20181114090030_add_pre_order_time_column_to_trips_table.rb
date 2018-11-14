class AddPreOrderTimeColumnToTripsTable < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :preorder_time, :datetime
  end
end
