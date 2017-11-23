ROM::SQL.migration do
  change do
    create_table(:subscriptions) do
      primary_key :id
      column :email, String, unique: true
      column :created_at, Time, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
