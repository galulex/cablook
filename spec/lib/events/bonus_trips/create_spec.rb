describe Events::BonusTrips::Create do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:friend) { create(:user) }
    let(:data) { { user_id: create(:user).id, friend_id: friend.id } }

    context 'and bonus trip created' do
      let(:bonus) { BonusTrip.last }

      it { is_expected.to change { BonusTrip.count }.by(+1) }

      it do
        subject.call
        expect(bonus[:status]).to eq(Constants::BonusTrip::STATUSES[Constants::BonusTrip::ICED])
      end

      context 'when referral have finished trips' do
        before { create(:trip, user_id: friend.id, status: Constants::Trip::FINISHED) }

        it do
          subject.call
          expect(bonus[:status]).to eq(Constants::BonusTrip::STATUSES[Constants::BonusTrip::FRESH])
        end
      end
    end

    context 'when user_id and friend_id are equals' do
      let(:user) { create(:user) }
      let(:data) { { user_id: user.id, friend_id: user.id } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when user_id is missing' do
      let(:data) { super().except(:user_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
