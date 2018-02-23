describe Operations::Wayforpay::Refund do
  let(:instance) { described_class.new(trip.id) }
  let(:wayforpay_body) { { reasonCode: 1100 }.to_json }

  before { allow(Wayforpay::Payments).to receive(:refund) { OpenStruct.new(body: wayforpay_body) } }

  describe '#call' do
    let!(:trip) { Factory[:trip, user_id: user.id] }
    let!(:payment) { Factory[:payment, trip_id: trip.id] }
    let(:user) { Factory[:user] }

    context 'when status is ok' do
      before { instance.call }

      it { expect(payment_repository.payments.to_a.last.status).to eq(Constants::Payments::REFUND) }
    end

    context 'when payment status is pending' do
      let!(:payment) { Factory[:payment, trip_id: trip.id, status: Constants::Payments::PENDING] }

      before { instance.call }

      it { expect(payment_repository.payments.to_a.last.status).to eq(Constants::Payments::REFUND) }
    end

    context 'when smth went wrong' do
      let(:wayforpay_body) { { reasonCode: '1111' }.to_json }
      let!(:payment) { Factory[:payment, trip_id: trip.id, status: Constants::Payments::HOLD] }

      before { instance.call }

      it { expect(payment_repository.payments.to_a.last.status).to eq(Constants::Payments::HOLD) }
    end

    context 'when payment by bonus' do
      let!(:payment) { Factory[:payment, trip_id: trip.id, status: Constants::Payments::BONUS] }
      let!(:bonus_trip) { Factory[:bonus_trip, trip_id: trip.id, status: Constants::BonusTrip::USED] }

      before { instance.call }

      it { expect(bonus_trip_repository.by_id(bonus_trip.id).status).to eq(Constants::BonusTrip::NEW) }
    end
  end
end
