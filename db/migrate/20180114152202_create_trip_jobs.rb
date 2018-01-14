class CreateTripJobs < ActiveRecord::Migration[5.1]
  def change
    create_table :trip_jobs do |t|
      t.string :activejob_id
      t.string :sidekiq_id
      t.references :trip, foreign_key: true
    end
  end
end
