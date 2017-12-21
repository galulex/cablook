ROM::SQL.migration do
  change do
    add_column :cards, :currency, String
  end
end
