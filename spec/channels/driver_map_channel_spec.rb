describe DriverMapChannel do
  let(:channel) { described_class.new(connection, {}) }
  let(:connection) { TestConnection.new }

  context '#send_location' do
    let(:trip) {create(:trip, car_id: car.id, status: Constants::Trip::DRIVING)}
    let(:car) {create(:car)}
    let(:latitude) { 50.846042486788605 }
    let(:longitude) { 14.88 }
    let(:latitude_first) { 42.78437439386835 }
    let(:longitude_first) { 15.2 }
    let(:speed) { 20 }
    let(:data) do
      {
        'action' => 'send_location',
        'body' => {
          'latitude': latitude,
          'longitude': longitude,
          'car_id': car.id,
          'speed': speed
        }.to_json
      }
    end
    let(:data_first) do
      {
        'action' => 'send_location',
        'body' => {
          'latitude': latitude_first,
          'longitude': longitude_first,
          'car_id': car.id,
          'speed': speed
        }.to_json
      }
    end
    let(:data_overspeed) do
      {
        'action' => 'send_location',
        'body' => {
          'latitude': latitude,
          'longitude': longitude,
          'car_id': car.id,
          'speed': 90
        }.to_json
      }
    end
    let(:body) do
      {
        car_id: car.id,
        location: {
          latitude: latitude,
          longitude: longitude
        },
        car: {
          'deg' => 173.2511321253247,
          'dis' => 866.391195752578,
          'id' => car.id,
          'number' => car.number,
          'phone_number' => car.phone_number,
          'status' => car.status
        }
      }
    end

    let(:redis_car_location) { Redis.current.get("car_#{car.id}") }

    context 'that redis save location' do
      before do
        Redis.current.set("car_#{car.id}", "#{latitude},#{longitude}")
        channel.perform_action(data)
      end

      it { expect(redis_car_location).to eq("#{latitude},#{longitude}") }
    end

    context 'and have enqued job' do
      after { channel.perform_action(data_overspeed) }

      it { expect(Jobs::TelegramSendMessage).to receive(:perform_later) }
    end

    context 'and broadcast car location to this channel' do
      before do
        Redis.current.set("car_#{car.id}", "#{latitude},#{longitude}")
        channel.perform_action(data_first)
      end
      after { channel.perform_action(data) }

      context 'with current trip' do
        it do
          expect(ActionCable.server).to receive(:broadcast).with(
            Constants::Channels::DRIVER_MAP,
            action: Constants::BroadcastActions::SEND_LOCATION,
            car_id: car.id,
            location: [latitude, longitude],
            speed: speed,
            car: {
              'deg' => 173.2511321253247,
              'dis' => 866.391195752578,
              'id' => car.id,
              'number' => car.number,
              'phone_number' => car.phone_number,
              'status' => car.status,
            }
          ).once

          expect(ActionCable.server).to receive(:broadcast).with(
            "TripChannel_#{trip.id}",
            action: Constants::BroadcastActions::DRIVER_LOCATION_UPDATED,
            body: body
          ).once
        end
      end

      context 'without current trip' do
        let(:trip) { create(:trip, car_id: car.id, status: Constants::Trip::FINISHED)}
        it do
          expect(ActionCable.server).not_to receive(:broadcast).with(
            "TripChannel_#{trip.id}",
            action: Constants::BroadcastActions::DRIVER_LOCATION_UPDATED,
            body: body
          )
        end
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

  context '#sos' do
    let(:driver) { create(:driver, car_id: create(:car).id) }
    let(:data) do
      {
        'action' => 'sos',
        'body' => {
          'car_id': driver.car_id
        }.to_json
      }
    end

    after { channel.perform_action(data) }

    it do
      expect(ActionCable.server).to receive(:broadcast).with(
        Constants::Channels::DRIVER_MAP,
        data
      ).once
    end

    it { expect(Jobs::TelegramSendMessage).to receive(:perform_later) }
  end
end
