class CreateBusinesses < ActiveRecord::Migration[5.2]
  def change
    create_table :businesses do |t|
      t.references :user, foreign_key: true
      t.integer :card_id, index: true
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
