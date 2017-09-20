ROM::SQL.migration do
  change do
    create_table(:cars) do
      primary_key :id
      column :number, String, unique: true
      column :status, Integer
    end
  end
end
