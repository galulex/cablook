describe Events::Trips::Finish do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:trip) { Factory[:trip, status: Constants::Trip::PENDING] }

    let(:data) { { trip_id: trip.id } }

    it { is_expected.to change { trip_repository.by_id(trip.id).status }.to(Constants::Trip::FINISHED) }
    it { is_expected.to have_enqueued_job(Jobs::PaymentSettle) }

    context 'and broadcast to driver map channel' do
      it do
        expect(ActionCable.server).to receive(:broadcast).with(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::TRIP_FINISH_ACTION,
          body: { action: Constants::BroadcastActions::TRIP_FINISHED }
        ).once
        subject.call
      end
    end
  end
end
