Factory.define(:trip_job) do |f|
  f.activejob_id { fake(:number, :number, 10) }
  f.sidekiq_id { fake(:number, :number, 10) }
end
