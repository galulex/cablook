describe Operations::Wayforpay::Refund do
  let(:instance) { described_class.new(trip.id) }
  let(:wayforpay_body) { { reasonCode: 1100 }.to_json }

  before { allow(Wayforpay::Payments).to receive(:refund) { OpenStruct.new(body: wayforpay_body) } }

  describe '#call' do
    let!(:trip) { create(:trip, user_id: user.id) }
    let!(:payment) { create(:payment, trip_id: trip.id, user_id: user.id) }
    let(:user) { create(:user) }

    context 'when status is ok' do
      before { instance.call }

      it { expect(payment.reload.status).to eq(Constants::Payments::REFUND) }
    end

    context 'when payment not found' do
      let!(:payment) { create(:payment, user_id: user.id) }

      it do
        expect(Wayforpay::Payments).not_to receive(:hold)
        expect(instance).not_to receive(:update_payment_status)
        instance.call
      end
    end

    context 'when payment status is pending' do
      let!(:payment) { create(:payment, trip_id: trip.id, status: Constants::Payments::PENDING, user_id: trip.user_id) }

      before { instance.call }

      it { expect(payment.reload.status).to eq(Constants::Payments::REFUND) }
    end

    context 'when smth went wrong' do
      let(:wayforpay_body) { { reasonCode: '1111' }.to_json }
      let!(:payment) { create(:payment, trip_id: trip.id, status: Constants::Payments::HOLD, user_id: trip.user_id) }

      before { instance.call }

      it { expect(payment.reload.status).to eq(Constants::Payments::HOLD) }
    end

    context 'when payment by bonus' do
      let!(:payment) { create(:payment, trip_id: trip.id, status: Constants::Payments::BONUS, user_id: trip.user_id) }
      let!(:bonus_trip) { create(:bonus_trip, trip_id: trip.id, status: Constants::BonusTrip::USED, user_id: trip.user_id) }

      before { instance.call }

      it { expect(bonus_trip.reload.status).to eq(Constants::BonusTrip::NEW) }
    end

    context 'when fake taxi' do
      let!(:payment) { create(:payment, trip_id: trip.id, status: Constants::Payments::HOLD, card_id: card.id, user_id: trip.user_id) }
      let(:card) { create(:card) }
      let(:instance) { described_class.new(trip.id, fake: true) }

      before { allow(Wayforpay::Payments).to receive(:hold) }

      it do
        expect(Wayforpay::Payments).to receive(:hold).once
        instance.call
      end
    end
  end
end
