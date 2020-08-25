class UpdateCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :default, :boolean, default: false
    add_timestamps :cards, null: false, default: -> { 'NOW()' }
  end
end
