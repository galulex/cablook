class RemoveFieldsFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_columns :users, :encrypted_password, :verification_token, :confirmation_token
  end
end
