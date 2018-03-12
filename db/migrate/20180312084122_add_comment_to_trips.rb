class AddCommentToTrips < ActiveRecord::Migration[5.1]
  def change
    add_column :trips, :comment, :string
  end
end
