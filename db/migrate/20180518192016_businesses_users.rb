class BusinessesUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :businesses_users, id: false do |t|
      t.integer :business_id
      t.integer :user_id
    end
    add_index :businesses_users, [:business_id, :user_id], unique: true
  end
end
