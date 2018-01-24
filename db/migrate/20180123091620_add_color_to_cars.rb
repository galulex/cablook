class AddColorToCars < ActiveRecord::Migration[5.1]
  def change
    add_column :cars, :color, :string
  end
end
