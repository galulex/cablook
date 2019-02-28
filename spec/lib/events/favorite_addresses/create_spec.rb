describe Events::FavoriteAddresses::Create do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { { id: 1, name: 'test', location: '49.4241406,32.0362413', user_id: user.id } }
    let!(:user) { create(:user) }

    context 'when favorite address is created successfully' do
      it { is_expected.to change { FavoriteAddress.count }.by(+1) }
    end

    context 'when user with data number not found' do
      let(:data) { super().merge(user_id: 9999) }

      it { is_expected.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end
end
