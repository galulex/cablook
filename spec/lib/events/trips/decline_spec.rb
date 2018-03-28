describe Events::Trips::Decline do
  describe '.call' do
    let(:trip) { Factory[:trip, status: Constants::Trip::PENDING] }

    let(:data) { { trip_id: trip.id } }

    subject { -> { described_class.call(data) } }

    it { is_expected.to change { trip_repository.by_id(trip.id).status }.to(Constants::Trip::DECLINED) }

    context 'when nothing happened' do
      let(:trip) { Factory[:trip, status: Constants::Trip::FINISHED] }

      it { is_expected.not_to change { trip_repository.by_id(trip.id).status } }
    end

    context 'and broadcast to channel' do
      after { subject.call }

      it { expect(ActionCable.server).to receive(:broadcast).twice }
    end
  end
end
