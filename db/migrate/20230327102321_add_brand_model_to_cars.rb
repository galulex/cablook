class AddBrandModelToCars < ActiveRecord::Migration[5.2]
  def change
    add_column :cars, :brand, :string
    add_column :cars, :model, :string
  end
end
