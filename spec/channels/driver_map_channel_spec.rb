describe DriverMapChannel do
  let(:channel) { described_class.new(connection, {}) }
  let(:connection) { TestConnection.new }

  context '#send_location' do
    let(:trip) {create(:trip, car_id: car.id, status: Constants::Trip::DRIVING)}
    let(:car) {create(:car)}
    let(:latitude) { 49.426168 }
    let(:longitude) { 32.054251 }
    let(:latitude_first) { 42.78437439386835 }
    let(:longitude_first) { 15.2 }
    let(:speed) { 20 }
    let(:overspeed) { 90 }
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
          'speed': overspeed
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
          'deg' => 155.65681685979482,
          'dis' => 1991.1805060912232,
          'id' => car.id,
          'number' => car.number,
          'phone_number' => car.phone_number,
          'status' => car.status,
          'brand' => car.brand,
          'model' => car.model
        }
      }
    end

    context 'speedlimit' do
      before { Redis.current.set("car_#{car.id}", "#{latitude},#{longitude}") }

      context 'when overspeed' do
        before { Redis.current.set("max_#{car.id}", overspeed) }

        after { channel.perform_action(data) }

        it { expect(Jobs::TelegramSendMessage).to receive(:perform_later) }
      end

      context 'when speed acceptable' do
        before { Redis.current.set("max_#{car.id}", speed) }

        after { channel.perform_action(data) }

        it { expect(Jobs::TelegramSendMessage).to_not receive(:perform_later) }
      end

      context 'when feature disabled' do
        before { Settings.get.update!(overspeed_notify: false) }

        after { channel.perform_action(data_overspeed) }

        it { expect(Jobs::TelegramSendMessage).to_not receive(:perform_later) }
      end
    end

    context 'that redis save location' do
      let(:redis_car_location) { Redis.current.get("car_#{car.id}") }

      before do
        Redis.current.set("car_#{car.id}", "#{latitude},#{longitude}")
        channel.perform_action(data)
      end

      it { expect(redis_car_location).to eq("#{latitude},#{longitude}") }
    end

    context 'and not have enqued job' do
      before do
        Redis.current.set("car_#{car.id}", "#{latitude},#{longitude}")
        channel.perform_action(data)
      end

      it { expect(Jobs::TelegramSendMessage).not_to receive(:perform_later) }
    end

    context 'and have enqued job' do
      before do
        Redis.current.set("car_#{car.id}", "#{latitude},#{longitude}")
        Redis.current.set("max_#{car.id}", overspeed)
        expect(Jobs::TelegramSendMessage).to receive(:perform_later)
      end

      it { channel.perform_action(data) }
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
              'deg' => 155.65681685979482,
              'dis' => 1991.1805060912232,
              'id' => car.id,
              'number' => car.number,
              'phone_number' => car.phone_number,
              'status' => car.status,
              'brand' => car.brand,
              'model' => car.model
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

    context 'when feature is disabled' do
      before { Settings.get.update!(sos: false) }

      after { channel.perform_action(data) }

      it do
        expect(ActionCable.server).to_not receive(:broadcast).with(
          Constants::Channels::DRIVER_MAP,
          data
        )
      end
    end
  end
end
