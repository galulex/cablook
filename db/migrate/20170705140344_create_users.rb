ROM::SQL.migration do
  change do
    create_table(:users) do
      primary_key :id
      column :email, String, unique: true
      column :encrypted_password, String
      column :auth_token, String
    end
  end
end
