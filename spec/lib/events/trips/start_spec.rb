describe Events::Trips::Start do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:trip) { create(:trip, status: Constants::Trip::WAITING_CLIENT) }

    let(:data) { { trip_id: trip.id } }

    it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::DRIVING]) }

    context 'and broadcast to driver map channel' do
      it do
        expect(ActionCable.server).to receive(:broadcast).with(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::TRIP_START_ACTION,
          body: { action: Constants::BroadcastActions::TRIP_STARTED }
        ).once
        subject.call
      end
    end
  end
end
