class CreateTips < ActiveRecord::Migration[5.2]
  def change
    create_table :tips do |t|
      t.integer :amount
      t.references :trip, foreign_key: true
    end
  end
end
