describe Repositories::BonusTrip do
  describe '#by_user' do
    subject { bonus_trip_repository.by_user(user.id) }

    let(:user) { Factory[:user] }

    it { is_expected.to be_empty }

    context 'when user has trips' do
      before { Factory[:bonus_trip, user_id: user.id] }

      it { is_expected.not_to be_empty }
    end
  end

  describe '#available_by_user' do
    subject { bonus_trip_repository.available_by_user(user.id) }

    let(:user) { Factory[:user] }

    it { is_expected.to be_empty }

    context 'when user has bonus trips but used' do
      before { Factory[:bonus_trip, user_id: user.id, status: Constants::BonusTrip::USED] }

      it { is_expected.to be_empty }
    end

    context 'when user has bonus trips ' do
      before { Factory[:bonus_trip, user_id: user.id, status: Constants::BonusTrip::NEW] }

      it { is_expected.not_to be_empty }
    end
  end

  describe '#by_friend' do
    subject { bonus_trip_repository.by_friend(user.id) }

    let(:user) { Factory[:user] }

    it { is_expected.to be_empty }

    context 'when user has trips' do
      before { Factory[:bonus_trip, friend_id: user.id] }

      it { is_expected.not_to be_empty }
    end
  end

  describe '#frozen_by_friend' do
    subject { bonus_trip_repository.frozen_by_friend(user.id) }

    let(:user) { Factory[:user] }

    before { Factory[:bonus_trip, friend_id: user.id, status: Constants::BonusTrip::NEW] }

    it { is_expected.to be_empty }

    context 'when user has trips' do
      before { Factory[:bonus_trip, friend_id: user.id, status: Constants::BonusTrip::FROZEN] }

      it { is_expected.not_to be_empty }
    end
  end

  describe '#by_trip' do
    subject { bonus_trip_repository.by_trip(trip.id) }

    let(:trip) { Factory[:trip] }

    it { is_expected.to be nil }

    context 'when bonus by trip is present' do
      before { Factory[:bonus_trip, trip_id: trip.id] }

      it { is_expected.to be }
    end
  end
end
