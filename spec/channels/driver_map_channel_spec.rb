describe DriverMapChannel do
  let(:channel) { described_class.new(connection, {}) }
  let(:connection) { TestConnection.new }

  context '#send_location' do
    let(:trip) { create(:trip, car_id: car.id, status: Constants::Trip::DRIVING) }
    let(:car) { create(:car) }
    let(:latitude) { 49.426168 }
    let(:longitude) { 32.054251 }
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
          'speed': speed,
          'current_trips': [trip.id]
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
    let(:body) do
      {
        car_id: car.id,
        location: {
          latitude: latitude,
          longitude: longitude
        }
      }
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

    context 'and broadcast car location' do
      before do
        Redis.current.set("car_#{car.id}", "#{latitude},#{longitude}")
        channel.perform_action(data_first)
      end

      after { channel.perform_action(data) }

      it 'enqueues job in the broadcast_location queue' do
        expect { Jobs::BroadcastDriverLocation.perform_later(car.id, [latitude, longitude], speed, [trip.id])}.
          to have_enqueued_job(Jobs::BroadcastDriverLocation).on_queue('broadcast_location')
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

    it { expect(Jobs::TelegramSendMessage).to_not receive(:perform_later) }

    context 'when feature is disabled' do
      before { Settings.disable(:sos) }

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
