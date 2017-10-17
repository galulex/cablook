describe Repositories::Trip do
  describe '#by_user' do
    subject { described_class.new.by_user(user.id) }

    let(:user) { Factory[:user] }

    it { is_expected.to be_empty }

    context 'when user has trips' do
      let!(:trip) { Factory[:trip, user_id: user.id] }

      it { is_expected.not_to be_empty }
    end
  end

  describe '#by_pk_with_feedbacks' do
    let(:instance) { described_class.new.by_pk_with_feedbacks(trip.id) }
    let(:trip) { Factory[:trip] }

    it { expect(instance.id).to eq(trip.id) }
    it { expect(instance.feedbacks).to be_empty }

    context 'when trip has feedbacks' do
      let!(:feedback) { Factory[:feedback, trip_id: trip.id] }

      it { expect(instance.feedbacks).not_to be_empty }
    end
  end
end
