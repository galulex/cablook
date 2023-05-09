class AddAllowedUsersToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :allowed_users, :string
  end
end
