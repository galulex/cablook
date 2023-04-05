describe Events::Users::AddReferral do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:referrer) { create(:user) }
    let(:user) { create(:user) }
    let(:data) { { referral_code: referrer.referral_code, referral_id: user.id } }

    it { is_expected.to_not change { BonusTrip.count } }

    context 'when user already have referrer' do
      before { create(:bonus_trip, user_id: create(:user).id, friend_id: user.id) }

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
