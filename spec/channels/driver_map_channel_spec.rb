describe DriverMapChannel do
  let(:channel) { described_class.new(connection, {}) }
  let(:connection) { TestConnection.new }

  context '#send_location' do
    let(:car) {create(:car)}
    let(:latitude) { 50.846042486788605 }
    let(:longitude) { 14.88 }
    let(:data) do
      {
        'action' => 'send_location',
        'body' => {
          'latitude': latitude,
          'longitude': longitude,
          'car_id': car.id
        }.to_json
      }
    end

    let(:redis_car_location) { Redis.current.get("car_#{car.id}") }

    context 'that redis save location' do
      before { channel.perform_action(data) }

      it { expect(redis_car_location).to eq("#{latitude},#{longitude}") }
    end

    context 'and broadcast car location to this channel' do
      after { channel.perform_action(data) }

      it do
        expect(ActionCable.server).to receive(:broadcast).with(
          Constants::Channels::DRIVER_MAP,
          action: Constants::BroadcastActions::SEND_LOCATION,
          car_id: car.id,
          location: [latitude, longitude],
          car: {
            'deg' => -63.266544604056165,
            'dis' => 5825.910733992778,
            'id' => car.id,
            'number' => car.number,
            'phone_number' => car.phone_number,
            'status' => car.status,
          }
        ).once
      end
    end
  end

  context '#accept_trip' do
    let(:driver) { create(:driver, car_id: create(:car).id) }
    let(:trip) { create(:trip, status: 0) }
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

    context 'when trip was accepted' do
      let(:trip) { create(:trip, status: Constants::Trip::ON_THE_WAY) }
    end

    context 'when data is invalid' do
      let(:data) { {} }
    end
  end
end
