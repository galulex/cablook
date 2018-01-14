describe Repositories::Payment do
  describe '#by_trip' do
    let(:instance) { payment_repository.by_trip(trip.id) }
    let!(:payment) { Factory[:payment] }
    let(:trip) { Factory[:trip] }

    it { expect(instance).to be nil }

    context 'when payment is found' do
      let!(:payment) { Factory[:payment, trip_id: trip.id] }

      it { expect(instance.id).to eq(payment.id) }
    end
  end
end
