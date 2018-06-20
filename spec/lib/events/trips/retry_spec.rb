describe Events::Trips::Retry do
  describe '.call' do
    let(:trip) { create(:trip, status: Constants::Trip::DECLINED) }

    let(:data) { { trip_id: trip.id } }

    subject { -> { described_class.call(data) } }

    it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::PENDING]) }
    it { is_expected.to have_enqueued_job(Jobs::DeclineTrip).with(trip.id) }

    context 'and broadcast to channel' do
      after { subject.call }

      it { expect(ActionCable.server).to receive(:broadcast).once }
    end
  end
end
