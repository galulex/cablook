class CreatePayments < ActiveRecord::Migration[5.1]
  def change
    create_table :payments do |t|
      t.decimal :amount
      t.integer :status, default: 0
      t.references :card, foreign_key: true
      t.references :trip, foreign_key: true
      t.references :driver, foreign_key: true
    end
  end
end
