RSpec.describe Jobs::BroadcastDriverLocation do
  describe '#perform' do
    let(:car) { create(:car, status: 1) }
    let(:coords) { '49.426168,32.054251' }
    let(:speed) { 20 }
    let(:current_trips) { [1, 2, 3] }

    before { Redis.current.set("car_#{car.id}", coords) }

    context 'broadcasts driver location' do
      before { Redis.current.set("car_data_#{car.id}", { speed: speed, current_trips: current_trips }.to_json) }

      it do
        expect(ActionCable.server).to receive(:broadcast)
          .with(Constants::Channels::DRIVER_MAP, { 
            action: Constants::BroadcastActions::SEND_LOCATION,
            car_id: car.id,
            location: ['49.426168','32.054251'],
            speed: speed }
          )

          current_trips.each do |trip_id|
            expect(ActionCable.server).to receive(:broadcast)
              .with("#{Constants::Channels::TRIP}_#{trip_id}", hash_including(
                action: Constants::BroadcastActions::DRIVER_LOCATION_UPDATED,
                body: {
                  car_id: car.id,
                  location: {
                    latitude: '49.426168',
                    longitude: '32.054251'
                  }
                }
              ))
          end

      described_class.perform_now()
      end
    end

    context 'does not broadcast to trip channels if current_trips is empty' do
      before { Redis.current.set("car_data_#{car.id}", { speed: speed, current_trips: [] }.to_json) }

      it do
         expect(ActionCable.server).to receive(:broadcast).once 

         described_class.perform_now()
      end
    end
  end
end