describe Operations::Wayforpay::Refund do
  let(:instance) { described_class.new(trip.id) }

  describe '#call' do
    subject { -> { instance.call } }

    let!(:trip) { Factory[:trip, user_id: user.id] }
    let!(:payment) { Factory[:payment, trip_id: trip.id] }
    let(:user) { Factory[:user] }


    context 'when status is ok' do
      before { subject.call }

      it { expect(payment_repository.payments.to_a.last.status).to eq(Constants::Payments::REFUND) }
    end

    context 'when smth went wrong' do
      it { expect(payment_repository.payments.to_a.last.status).to eq(Constants::Payments::PENDING) }
    end
  end
end
