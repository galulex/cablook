ROM::SQL.migration do
  change do
    alter_table(:payments) do
      add_column :status, Integer
      add_foreign_key :driver_id, :drivers
    end
  end
end
