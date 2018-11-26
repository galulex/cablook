class CreateUserTelegrams < ActiveRecord::Migration[5.2]
  def change
    create_table :user_telegrams do |t|
      t.references :user, foreign_key: true
      t.string :username, index: true
      t.string :chat_id

      t.timestamps
    end
  end
end
