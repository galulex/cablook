ROM::SQL.migration do
  change do
    create_table(:cards) do
      primary_key :id
      column :token, String, null: false
      column :pan, String
      column :type, String

      foreign_key :user_id, :users
    end
  end
end
