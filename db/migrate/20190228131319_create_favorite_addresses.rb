class CreateFavoriteAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :favorite_addresses do |t|
      t.string :name
      t.string :location
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
