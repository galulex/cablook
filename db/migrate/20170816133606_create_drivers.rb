ROM::SQL.migration do
  change do
    create_table(:drivers) do
      primary_key :id
      column :number, String
      column :encrypted_password, String
      column :auth_token, String
    end
  end
end
