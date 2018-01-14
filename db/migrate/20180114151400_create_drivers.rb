class CreateDrivers < ActiveRecord::Migration[5.1]
  def change
    create_table :drivers do |t|
      t.string :name
      t.string :useraname
      t.string :encrypted_password
      t.string :auth_token
      t.references :car, foreign_key: true
    end
  end
end
