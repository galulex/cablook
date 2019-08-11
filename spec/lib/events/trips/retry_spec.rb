describe Events::Trips::Retry do
  describe '.call' do
    let(:trip) { create(:trip, status: Constants::Trip::DECLINED) }
    let(:user) { create(:user) }
    let!(:card) { create(:card, user_id: user.id) }
    let!(:trip_payment) { create(:trip_payment, trip: trip, user: user, card: card, status: Constants::Payments::DECLINE) }

    let(:data) { { trip_id: trip.id } }

    subject { -> { described_class.call(data) } }

    it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::PENDING]) }
    it { is_expected.to change { trip_payment.reload.status }.to(Constants::Payments::PENDING) }
    it { is_expected.to have_enqueued_job(Jobs::DeclineTrip).with(trip.id) }

    context 'and broadcast to channel' do
      after { subject.call }

      it { expect(ActionCable.server).to receive(:broadcast).once }
    end

    context 'when payment by bonus' do
      let!(:bonus_trip) { create(:bonus_trip, trip: trip, user_id: user.id, status: Constants::BonusTrip::NEW) }

      after { subject.call }

      it { is_expected.to change { bonus_trip.reload.status }.to(Constants::BonusTrip::USED) }
      it { is_expected.to change { trip_payment.reload.status }.to(Constants::Payments::BONUS) }
    end
  end
end
