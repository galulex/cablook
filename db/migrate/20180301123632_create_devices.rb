class CreateDevices < ActiveRecord::Migration[5.1]
  def change
    create_table :devices do |t|
      t.string :token
      t.string :platform

      t.references :user, foreign_key: true
    end
  end
end
