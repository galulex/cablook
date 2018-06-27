describe Operations::Wayforpay::Settle do
  let(:instance) { described_class.new(trip.id) }
  let(:wayforpay_body) { { reasonCode: Constants::Payments::WAYFORPAY_SUCCESS }.to_json }

  before { allow(Wayforpay::Payments).to receive(:settle) { OpenStruct.new(body: wayforpay_body) } }

  describe '#call' do
    subject { -> { instance.call } }

    let!(:trip) { create(:trip, user_id: user.id, status: Constants::Trip::FINISHED) }
    let!(:payment) { create(:payment, trip_id: trip.id, user_id: user.id) }
    let(:user) { create(:user) }

    context 'when status is ok' do
      it { is_expected.to change { payment.reload.status }.to(Constants::Payments::SUCCESS) }

      it do
        expect(Wayforpay::Payments).to receive(:settle).once
        subject.call
      end

      context 'and give bonus trip for referrer' do
        let(:referrer) { create(:user) }
        let!(:bonus_trip) { create(:bonus_trip, user_id: referrer.id, friend_id: user.id) }

        it { is_expected.to change { bonus_trip.reload.status }.to(Constants::BonusTrip::NEW) }
      end
    end

    context 'when smth went wrong' do
      let(:wayforpay_body) { { reasonCode: '1111' }.to_json }
      let!(:payment) { create(:payment, trip_id: trip.id, user_id: user.id, status: Constants::Payments::HOLD) }

      before { subject.call }

      it { expect(payment.reload.status).to eq(Constants::Payments::PENDING) }
    end

    context 'when payment by bonus' do
      let!(:payment) { create(:payment, trip_id: trip.id, status: Constants::Payments::BONUS, user_id: user.id) }

      it { is_expected.not_to change { payment.reload.status } }

      it do
        expect(Wayforpay::Payments).not_to receive(:settle)
        subject.call
      end
    end

    context 'when payment not found' do
      let!(:payment) { create(:payment, user_id: user.id) }

      it do
        expect(Wayforpay::Payments).not_to receive(:settle)
        subject.call
      end
    end
  end
end
