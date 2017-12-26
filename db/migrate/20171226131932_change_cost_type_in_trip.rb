ROM::SQL.migration do
  change do
    alter_table(:trips) do
      set_column_type :cost, BigDecimal
    end
  end
end
