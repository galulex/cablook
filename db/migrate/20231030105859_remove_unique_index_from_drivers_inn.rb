class RemoveUniqueIndexFromDriversInn < ActiveRecord::Migration[5.2]
  def change
    remove_index :drivers, :inn
  end
end
