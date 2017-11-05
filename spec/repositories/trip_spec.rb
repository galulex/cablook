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
    let(:trip) { Factory[:trip] }
    let(:result) { described_class.new.by_pk_with_feedbacks(trip.id) }

    it { expect(result.id).to eq(trip.id) }
    it { expect(result.feedbacks).to be_empty }

    context 'when trip has feedbacks' do
      let!(:feedback) { Factory[:feedback, trip_id: trip.id] }

      it { expect(result.feedbacks).not_to be_empty }
    end
  end

  describe '#active_and_estimated_end_in_timeframe' do
    let!(:trip_new_busy) { Factory[:trip, status: Constants::Trip::PENDING, estimated_end_time: time + 5.minute] }
    let!(:trip_new_active) { Factory[:trip, status: Constants::Trip::DRIVING, estimated_end_time: time + 5.minute] }
    let!(:trip_old) { Factory[:trip, estimated_end_time: time - 1.day] }
    let(:time) { Time.new(2017, 0o1, 0o2, 0o3, 0o4, 0o5) }

    let(:result) { described_class.new.active_and_estimated_end_in_timeframe(from: time, till: time + 15.minutes) }

    it { expect(result.count).to eq(1) }
    it { expect(result.first[:id]).to eq(trip_new_active.id) }
  end
end
