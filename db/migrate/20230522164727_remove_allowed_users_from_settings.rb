class RemoveAllowedUsersFromSettings < ActiveRecord::Migration[5.2]
  def up
    remove_column :settings, :allowed_users
  end

  def down
    add_column :settings, :allowed_users, :string
  end
end
