class CreateCars < ActiveRecord::Migration[5.1]
  def change
    create_table :cars do |t|
      t.string :number
      t.integer :status, default: 0
    end
  end
end
