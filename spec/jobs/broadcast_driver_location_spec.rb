RSpec.describe Jobs::BroadcastDriverLocation do
  describe '#perform' do
    let(:car_id) { 1 }
    let(:coords) { [49.426168, 32.054251] }
    let(:speed) { 20 }
    let(:current_trips) { [1, 2, 3] }

    it 'broadcasts driver location' do
      expect(ActionCable.server).to receive(:broadcast)
        .with(Constants::Channels::DRIVER_MAP, hash_including(
          action: Constants::BroadcastActions::SEND_LOCATION,
          car_id: car_id,
          location: coords,
          speed: speed
        ))

      current_trips.each do |trip_id|
        expect(ActionCable.server).to receive(:broadcast)
          .with("#{Constants::Channels::TRIP}_#{trip_id}", hash_including(
            action: Constants::BroadcastActions::DRIVER_LOCATION_UPDATED,
            body: {
              car_id: car_id,
              location: {
                latitude: coords[0],
                longitude: coords[1]
              }
            }
          ))
      end

      described_class.perform_now(car_id, coords, speed, current_trips)
    end

    it 'does not broadcast to trip channels if current_trips is empty' do
      expect(ActionCable.server).to receive(:broadcast)
        .with(Constants::Channels::DRIVER_MAP, hash_including(
          action: Constants::BroadcastActions::SEND_LOCATION,
          car_id: car_id,
          location: coords,
          speed: speed
        ))

      expect(ActionCable.server).not_to receive(:broadcast)

      described_class.perform_now(car_id, coords, speed, [])
    end
  end
end