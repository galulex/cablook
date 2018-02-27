class AddCreatedAtToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :created_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
