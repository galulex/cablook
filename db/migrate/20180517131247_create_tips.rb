class CreateTips < ActiveRecord::Migration[5.2]
  def change
    create_table :tips do |t|
      t.references :trip, foreign_key: true
      t.integer :amount
      t.jsonb :response
    end
  end
end
