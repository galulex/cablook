ROM::SQL.migration do
  change do
    create_table(:subscriptions) do
      primary_key :id
      column :email, String, unique: true
      column :created_at, Time
    end
  end
end
