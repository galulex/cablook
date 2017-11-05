ROM::SQL.migration do
  change do
    create_table(:trips) do
      primary_key :id
      column :status, Integer, default: 0
      column :path, String
      column :cost, BigDecimal

      column :departure, 'text[]', null: false
      column :destination, 'text[]', null: false

      column :estimated_end_time, DateTime

      foreign_key :user_id, :users
      foreign_key :driver_id, :drivers
      foreign_key :car_id, :cars
    end
  end
end
