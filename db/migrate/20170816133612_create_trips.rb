ROM::SQL.migration do
  change do
    create_table(:trips) do
      primary_key :id
      column :status, Integer
      column :path, String
      column :cost, BigDecimal

      foreign_key :user_id, :users
      foreign_key :driver_id, :drivers
    end
  end
end
