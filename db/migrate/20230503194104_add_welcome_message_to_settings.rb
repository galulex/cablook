class AddWelcomeMessageToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :welcome_message, :string
  end
end
