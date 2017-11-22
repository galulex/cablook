describe SearchEngine::FindCar do
  let(:free_car) { nil }
  let(:busy_cars) { nil }
  let(:trip) { Factory[:trip] }

  before do
    allow(SearchEngine::FindCar::Free).to receive(:call) { free_car }
    allow(SearchEngine::FindCar::Busies).to receive(:call) { busy_cars }
  end

  subject { described_class.call(trip_id: trip.id) }

  it { is_expected.to be nil }

  describe '.call' do
    context 'when result from both' do
      let(:free_car) { { car_id: Factory[:car].id, duration: 500 } }
      let(:busy_cars) { [{ car_id: Factory[:car].id, duration: 300 }] }

      it { is_expected.to eq(free_car) }

      context 'when the busy car nearest than free car' do
        let(:free_car) { { car_id: Factory[:car].id, duration: 600 } }
        let(:busy_cars) { [{ car_id: Factory[:car].id, duration: 200 }] }

        it { is_expected.to eq(busy_cars) }
      end
    end

    context 'when nearest car is free car' do
      let(:free_car) { { car_id: Factory[:car].id, duration: 500 } }

      it { is_expected.to eq(free_car) }
    end

    context 'when nearest cars are busy cars' do
      let(:busy_cars) { [{ car_id: Factory[:car].id, duration: 200 }] }

      it { is_expected.to eq(busy_cars) }
    end
  end
end
