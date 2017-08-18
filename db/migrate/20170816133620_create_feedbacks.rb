ROM::SQL.migration do
  change do
    create_table(:feedbacks) do
      primary_key :id
      column :rate, Integer

      foreign_key :trip_id, :trips
      foreign_key :user_id, :users
    end
  end
end
