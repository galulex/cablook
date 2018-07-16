describe Operations::Wayforpay::Settle do
  let(:instance) { described_class.new(trip.id) }
  let(:wayforpay_body) { { reasonCode: Constants::Payments::WAYFORPAY_SUCCESS }.to_json }

  before { allow(Wayforpay::Payments).to receive(:hold) { OpenStruct.new(body: wayforpay_body) } }

  describe '#call' do
    subject { -> { instance.call } }

    let!(:trip) { create(:trip, user_id: user.id, status: Constants::Trip::FINISHED) }
    let!(:payment) { create(:payment, trip_id: trip.id, user_id: user.id, card_id: card.id) }
    let(:card) { create(:card, user_id: user.id) }
    let(:user) { create(:user) }

    context 'when status is ok' do
      it { is_expected.to change { payment.reload.status }.to(Constants::Payments::SUCCESS) }
      it { is_expected.to change { trip.reload.total }.from(0).to(payment.amount) }

      it do
        expect(Wayforpay::Payments).to receive(:hold).once
        subject.call
      end

      context 'and give bonus trip for referrer' do
        let(:referrer) { create(:user) }
        let!(:bonus_trip) { create(:bonus_trip, user_id: referrer.id, friend_id: user.id) }

        it { is_expected.to change { bonus_trip.reload.status }.to(Constants::BonusTrip::NEW) }
      end
    end

    context 'when payment by bonus' do
      let!(:payment) { create(:payment, trip_id: trip.id, status: Constants::Payments::BONUS, user_id: user.id) }

      it { is_expected.not_to change { payment.reload.status } }

      it do
        expect(Wayforpay::Payments).not_to receive(:hold)
        subject.call
      end
    end

    context 'when payment not found' do
      let!(:payment) { create(:payment, user_id: user.id) }

      it do
        expect(Wayforpay::Payments).not_to receive(:hold)
        subject.call
      end
    end
  end
end
