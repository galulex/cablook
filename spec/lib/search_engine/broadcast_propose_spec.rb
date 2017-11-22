describe SearchEngine::BroadcastPropose do
  describe '.call' do
    subject { -> { described_class.call(cars: cars, trip_id: trip.id, duration: duration) } }

    let(:car) { Factory[:car, status: 0] }
    let(:cars) { [car] }
    let(:trip) { Factory[:trip] }
    let(:duration) { 600 }

    let(:driver_map_channel) { Constants::Channels::DRIVER_MAP }
    let(:driver_map_channel_params) do
      { action: Constants::BroadcastActions::TRIP_PROPOSE,
        cars: cars,
        trip: trips_repository.by_id_with_user(trip.id).to_json }
    end
  end
end
