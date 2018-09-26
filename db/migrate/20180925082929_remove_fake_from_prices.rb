class RemoveFakeFromPrices < ActiveRecord::Migration[5.2]
  def change
    remove_column :prices, :fake, :integer
  end
end
