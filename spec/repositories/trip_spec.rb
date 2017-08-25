describe Repositories::Trip do
  describe '#by_user' do
    subject { described_class.new.by_user(user.id) }

    let(:user) { Factory[:user] }

    it { is_expected.to be_empty }

    context 'when user has a trips' do
      let!(:trip) { Factory[:trip, user_id: user.id] }

      it { is_expected.not_to be_empty }
    end
  end
end
