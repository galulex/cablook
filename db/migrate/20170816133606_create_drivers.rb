ROM::SQL.migration do
  change do
    create_table(:drivers) do
      primary_key :id
      column :name, String, unique: true
      column :auth_token, String, unique: true

      foreign_key :car_id

      index :auth_token
      index :car_id, unique: true
    end
  end
end
