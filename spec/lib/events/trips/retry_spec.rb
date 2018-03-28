describe Events::Trips::Retry do
  describe '.call' do
    let(:trip) { Factory[:trip, status: Constants::Trip::DECLINED] }

    let(:data) { { trip_id: trip.id } }

    subject { -> { described_class.call(data) } }

    it { is_expected.to change { trip_repository.by_id(trip.id).status }.to(Constants::Trip::PENDING) }

    context 'and broadcast to channel' do
      after { subject.call }

      it { expect(ActionCable.server).to receive(:broadcast).once }
    end
  end
end
