class CreateSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :subscriptions do |t|
      t.string :email
      t.datetime :created_at, default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
