describe Events::BonusTrips::Create do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:friend) { Factory[:user] }
    let(:data) { { user_id: Factory[:user].id, friend_id: friend.id } }

    context 'and bonus trip created' do
      let(:bonus) { bonus_trip_repository.bonus_trips.last }

      it { is_expected.to change { bonus_trip_repository.bonus_trips.count }.by(+1) }

      it do
        subject.call
        expect(bonus[:status]).to eq(Constants::BonusTrip::FROZEN)
      end

      context 'when referral have finished trips' do
        before { Factory[:trip, user_id: friend.id, status: Constants::Trip::FINISHED] }

        it do
          subject.call
          expect(bonus[:status]).to eq(Constants::BonusTrip::NEW)
        end
      end
    end

    context 'when user_id and friend_id are equals' do
      let(:user) { Factory[:user] }
      let(:data) { { user_id: user.id, friend_id: user.id } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when user_id is missing' do
      let(:data) { super().except(:user_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
