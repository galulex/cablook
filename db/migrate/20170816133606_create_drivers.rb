ROM::SQL.migration do
  change do
    create_table(:drivers) do
      primary_key :id
      column :name, String, unique: true
      column :auth_token, String

      index :auth_token
    end
  end
end
