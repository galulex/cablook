class CreateCards < ActiveRecord::Migration[5.1]
  def change
    create_table :cards do |t|
      t.string :token
      t.string :pan
      t.string :type
      t.string :currency
      t.references :user, foreign_key: true
    end
  end
end
