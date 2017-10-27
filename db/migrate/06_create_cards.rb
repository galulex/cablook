ROM::SQL.migration do
  change do
    create_table(:cards) do
      primary_key :id
      column :token, String
      column :last_4, Integer

      foreign_key :user_id, :users
    end
  end
end
