class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :phone_number
      t.string :encrypted_password
      t.string :auth_token
      t.string :verification_token
      t.string :confirmation_token
    end
  end
end
