describe Events::Trips::Decline do
  describe '.call' do
    let(:trip) { create(:trip, status: Constants::Trip::PENDING) }

    let(:data) { { trip_id: trip.id } }

    subject { -> { described_class.call(data) } }

    let!(:payment) { create(:payment, trip_id: trip.id, user_id: trip.user.id) }

    it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::DECLINED]) }
    it { is_expected.to change { payment.reload.status }.to(Constants::Payments::DECLINE) }

    context 'when nothing happened' do
      let(:trip) { create(:trip, status: Constants::Trip::FINISHED) }

      it { is_expected.not_to change { trip.reload.status } }
    end

    context 'when payment by bonus' do
      let!(:payment) { create(:payment, trip_id: trip.id, status: Constants::Payments::BONUS, user_id: trip.user_id) }
      let!(:bonus_trip) { create(:bonus_trip, trip_id: trip.id, status: :used, user_id: trip.user_id) }

      before { Settings.get.update!(bonuses: true) }

      it { is_expected.to change { bonus_trip.reload.fresh? }.to be_truthy }
    end

    context 'and broadcast to channel' do
      after { subject.call }

      it { expect(ActionCable.server).to receive(:broadcast).twice }
    end
  end
end
