class DropTripJobs < ActiveRecord::Migration[5.2]
  def change
    drop_table :trip_jobs
  end
end
