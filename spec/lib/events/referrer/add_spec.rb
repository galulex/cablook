describe Events::Referrers::Add do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:referrer) { Factory[:user] }
    let(:user) { Factory[:user] }
    let(:data) { { referral_code: referrer.referral_code, referral_id: user.id } }

    it { is_expected.to change { bonus_trip_repository.bonus_trips.count }.by(+1) }

    context 'when user already have referrer' do
      before { Factory[:bonus_trip, friend_id: user.id] }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when no users with referral_code' do
      let(:data) { { referral_code: 'test', referral_id: user.id } }

      it { is_expected.to raise_error(Constants::NotFoundError) }
    end

    context 'when referral_code is empty' do
      let(:data) { { referral_id: user.id } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
