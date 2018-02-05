class CreateBonusTrip < ActiveRecord::Migration[5.1]
  def change
    create_table :bonus_trips do |t|
      t.integer :status, default: 0
      t.references :user, foreign_key: true
      t.references :friend, foreign_key: { to_table: :users }
      t.references :trip, foreign_key: true
      t.string :code
    end
  end
end
