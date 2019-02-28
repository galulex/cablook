describe Events::FavoriteAddresses::Create do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { attributes_for(:favorite_address).merge(user_id: user.id) }
    let!(:user) { create(:user) }

    context 'when favorite address is created successfully' do
      it { is_expected.to change { FavoriteAddress.count }.by(+1) }
    end

    context 'when user not found (by id)' do
      let(:data) { super().merge(user_id: nil) }

      it { is_expected.to raise_error ArgumentError }
    end
  end
end
