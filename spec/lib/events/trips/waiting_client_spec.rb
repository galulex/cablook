describe Events::Trips::WaitingClient do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:trip) { create(:trip, status: Constants::Trip::ON_THE_WAY) }

    let(:data) { { trip_id: trip.id } }

    it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::WAITING_CLIENT]) }

    context 'and broadcast to driver map channel' do
      it do
        expect(ActionCable.server).to receive(:broadcast).with(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::TRIP_WAITING_ACTION,
          body: { action: Constants::BroadcastActions::TRIP_WAITING }
        ).once
        subject.call
      end
    end
  end
end
