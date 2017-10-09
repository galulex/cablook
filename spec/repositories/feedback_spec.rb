describe Repositories::Feedback do
  describe '#by_trip' do
    subject { described_class.new.by_trip(trip.id) }

    let(:trip) { Factory[:trip] }

    it { is_expected.to be_empty }

    context 'when trip has feedbacks' do
      let!(:feedback) { Factory[:feedback, trip_id: trip.id] }

      it { is_expected.not_to be_empty }
    end
  end
end
