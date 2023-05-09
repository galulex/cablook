class RenameWelcomeMessageToBeforeCreateTripMessage < ActiveRecord::Migration[5.2]
  def change
    rename_column :settings, :welcome_message, :before_create_trip_message
  end
end
