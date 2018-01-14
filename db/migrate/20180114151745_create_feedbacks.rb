class CreateFeedbacks < ActiveRecord::Migration[5.1]
  def change
    create_table :feedbacks do |t|
      t.integer :rate, default: 0
      t.text :description
      t.references :trip, foreign_key: true
      t.references :user, foreign_key: true
    end
  end
end
