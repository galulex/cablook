describe Repositories::Card do
  describe '#by_user_id' do
    subject { card_repository.by_user(user.id) }

    let(:user) { Factory[:user] }

    it { is_expected.to be_empty }

    context 'when user has trips' do
      before { Factory[:card, user_id: user.id] }

      it { is_expected.not_to be_empty }
    end
  end
end
