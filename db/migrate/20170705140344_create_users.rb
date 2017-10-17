ROM::SQL.migration do
  change do
    create_table(:users) do
      primary_key :id

      column :email, String, unique: true
      column :phone_number, String, unique: true, null: false
      column :encrypted_password, String
      column :auth_token, String, unique: true
      column :verification_token, String, unique: true
      column :confirmation_token, String, unique: true

      index :auth_token
    end
  end
end
