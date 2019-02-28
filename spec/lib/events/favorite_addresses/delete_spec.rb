describe Events::FavoriteAddresses::Delete do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let!(:data) { { id: favorite_address.id, user_id: user.id } }
    let(:favorite_address) { create(:favorite_address, user_id: user.id) }
    let(:user) { create(:user) }

    it { is_expected.to change { FavoriteAddress.count }.by(-1) }

    context 'when favorite address not found' do
      let(:favorite_address) { create(:favorite_address) }

      it { is_expected.not_to change { FavoriteAddress.count } }
    end
  end
end
