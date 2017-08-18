ROM::SQL.migration do
  change do
    create_table(:payments) do
      primary_key :id
      column :amount, BigDecimal

      foreign_key :card_id, :cards
      foreign_key :trip_id, :trips
    end
  end
end
