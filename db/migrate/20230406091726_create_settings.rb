class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.boolean :bonuses, default: false
      t.boolean :cashback, default: false
    end

    Settings.create
  end
end
