ROM::SQL.migration do
  change do
    add_column :payments, :status, Integer

    alter_table(:payments) do
      add_foreign_key :driver_id, :drivers
    end
  end
end
