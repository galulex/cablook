describe SearchEngine do
  describe '.call' do
    subject { -> { described_class.call(trip_id: trip.id) } }

    let(:trip) { Factory[:trip] }
    let(:car) { Factory[:car] }
    let(:car_params) { { car_id: car.id, trip_id: trip.id } }

    before { allow(SearchEngine::FindCar).to receive(:call) { car_params } }

    context 'when car will assign and broadcar to channel' do
      after { subject.call }

      it { expect(SearchEngine::AssignAndBroadcast).to receive(:call).with(car_id: car.id, trip_id: trip.id) }
    end

    context 'when trip propose is broadcasted' do
      let(:car_params) { [{ car_id: car.id, trip_id: trip.id }] }

      after { subject.call }

      it { expect(SearchEngine::BroadcastPropose).to receive(:call).with(cars: car_params, trip_id: trip.id) }
    end

    context 'when car found' do
      let(:car_params) { nil }

      before { ActiveJob::Base.queue_adapter = :test }

      it { is_expected.to have_enqueued_job(SearchCarForTripJob).with(trip.id) }
    end
  end
end
