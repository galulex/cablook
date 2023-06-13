task broadcast_location: :environment do
  19.times do
    Jobs::BroadcastDriverLocation.perform_later
    sleep 3.seconds
  end
end
