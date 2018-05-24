describe Repositories::Trip do
  describe '#all' do
    let(:instance) { trip_repository.all }

    it { expect(instance).to be_empty }

    context 'when trips are found' do
      let!(:trip) { Factory[:trip] }

      it { expect(instance).not_to be_empty }
    end
  end

  describe '#by_user_and_status' do
    subject { trip_repository.by_user_and_status(user.id, attrs) }

    let(:attrs) { {} }
    let(:user) { Factory[:user] }
    let!(:trip) { Factory[:trip] }

    it { is_expected.to be_empty }

    context 'when user has trips' do
      before { Factory[:trip, user_id: user.id] }

      it { is_expected.not_to be_empty }
    end

    context 'when by status' do
      let!(:trip) { Factory[:trip, user_id: user.id, status: Constants::Trip::PENDING] }

      it { is_expected.not_to be_empty }

      context 'and status is set' do
        let(:attrs) { { status: [Constants::Trip::PENDING] } }

        it { is_expected.not_to be_empty }
      end

      context 'but not found' do
        let(:attrs) { { status: Constants::Trip::ON_THE_WAY } }

        it { is_expected.to be_empty }
      end
    end
  end

  describe '#by_pk_with_feedbacks' do
    let(:trip) { Factory[:trip] }
    let(:result) { trip_repository.by_pk_with_feedbacks(trip.id) }

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

    let(:result) { trip_repository.active_and_estimated_end_in_timeframe(from: time, till: time + 15.minutes) }

    it { expect(result.count).to eq(1) }
    it { expect(result.first[:id]).to eq(trip_new_active.id) }
  end

  describe '#by_id_with_user' do
    let!(:trip_with_user) { Factory[:trip, user_id: user.id] }
    let!(:trip) { Factory[:trip, user_id: nil] }
    let(:user) { Factory[:user] }

    context 'when trip found' do
      let(:result) { trip_repository.by_id_with_user(trip_with_user.id) }

      it { expect(result).not_to be nil }
      it { expect(result.id).to eq(trip_with_user.id) }
    end

    context 'when trip without user' do
      let(:result) { trip_repository.by_id_with_user(trip.id) }

      it { expect(result).to be nil }
    end

    context 'when trip not found' do
      let(:result) { trip_repository.by_id_with_user(9999) }

      it { expect(result).to be nil }
    end
  end

  describe '#currents' do
    let(:driver) { Factory[:driver] }

    before do
      2.times do
        trip = Factory[:trip, status: Constants::Trip::ON_THE_WAY, user_id: Factory[:user].id, driver_id: driver.id]
        Factory[:payment, trip_id: trip.id]
      end

      Factory[:trip, status: Constants::Trip::PENDING, user_id: Factory[:user].id, driver_id: driver.id]
    end

    context 'when trip found' do
      let(:result) { trip_repository.currents(driver.id) }

      it { expect(result.count).to eq(2) }
    end
  end
end
