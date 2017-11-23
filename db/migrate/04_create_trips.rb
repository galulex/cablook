ROM::SQL.migration do
  change do
    create_table(:trips) do
      primary_key :id
      column :status, Integer, default: 0
      column :path, String
      column :cost, Integer

      column :departure, 'text[]', null: false
      column :destination, 'text[]', null: false
      column :departure_address, String
      column :destination_address, String

      column :estimated_end_time, DateTime
      column :created_at, DateTime, default: Sequel::CURRENT_TIMESTAMP

      foreign_key :user_id, :users
      foreign_key :driver_id, :drivers
      foreign_key :car_id, :cars
    end
  end
end
