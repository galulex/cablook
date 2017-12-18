ROM::SQL.migration do
  change do
    create_table(:trip_jobs) do
      primary_key :id
      column :activejob_id, String
      column :sidekiq_id, String

      foreign_key :trip_id, :trips
    end
  end
end
