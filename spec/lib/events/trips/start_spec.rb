describe Events::Trips::Start do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:trip) { Factory[:trip, status: Constants::Trip::WAITING_CLIENT] }

    let(:data) { { trip_id: trip.id } }

    it { is_expected.to change { trip_repository.by_id(trip.id).status }.to(Constants::Trip::DRIVING) }

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
