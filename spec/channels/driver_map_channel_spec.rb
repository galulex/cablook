describe DriverMapChannel do
  let(:channel) { described_class.new(connection, {}) }
  let(:connection) { TestConnection.new }

  context '#send_location' do
    let(:car_id) { 0 }
    let(:latitude) { Faker::Address.latitude }
    let(:latitude) { Faker::Address.longitude }
    let(:longitude) { 14.88 }
    let(:data) do
      {
        'action' => 'send_location',
        'body' => {
          'latitude': latitude,
          'longitude': longitude,
          'car_id': car_id
        }.to_json
      }
    end

    let(:redis_car_location) { Redis.new.get("car_#{car_id}") }

    context 'that redis save location' do
      before { channel.perform_action(data) }

      it { expect(redis_car_location).to eq([latitude, longitude].to_s) }
    end

    context 'and broadcast car location to this channel' do
      after { channel.perform_action(data) }

      it do
        expect(ActionCable.server).to receive(:broadcast).with(
          Constants::Channels::DRIVER_MAP,
          action: Constants::BroadcastActions::SEND_LOCATION,
          car_id: car_id,
          location: [latitude, longitude]
        ).once
      end
    end
  end

  context '#accept_trip' do
    let(:driver) { Factory[:driver, car_id: Factory[:car].id] }
    let(:trip) { Factory[:trip, status: 0] }
    let(:data) do
      {
        'action' => 'accept_trip',
        'body' => {
          'car_id': driver.car_id,
          'driver_id': driver.id,
          'trip_id': trip.id
        }.to_json
      }
    end

    after { channel.perform_action(data) }

    it { expect(Events::Trips::Accept).to receive(:call).once }
    it do
      expect(ActionCable.server).to receive(:broadcast).with(
        Constants::Channels::DRIVER_MAP,
        action: Constants::BroadcastActions::TRIP_ACCEPTED,
        trip_id: trip.id
      ).once
    end

    context 'when trip was accepted' do
      let(:trip) { Factory[:trip, status: Constants::Trip::ON_THE_WAY] }
    end

    context 'when data is invalid' do
      let(:data) { {} }
    end
  end
end
