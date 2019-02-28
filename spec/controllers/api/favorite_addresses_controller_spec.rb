describe Api::FavoriteAddressesController, type: :controller do
  let(:user) { create(:user, auth_token: 'token') }
  let(:auth_token) { user.auth_token }

  before { request.headers['Auth-Token'] = auth_token }

  describe '#index' do
    let!(:favorite_address) { create(:favorite_address, user_id: user.id) }

    subject { JSON.parse(response.body)['favorite_addresses'] }

    context 'favorite addresses' do
      before { get :index, as: :json }

      it 'returns all favorite addresses' do
        expect(subject.size).to eql(1)
      end
    end
  end

  describe '#create' do
    subject { response }

    let(:params) { { id: 1, name: 'test', location: '49.4241406,32.0362413', user_id: user.id } }

    before { post :create, params: params }

    it { is_expected.to be_successful }

    context 'when something went wrong' do
      let(:params) { super().merge(name: nil) }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end

  describe '#delete' do
    subject { response }
    let(:params) { { id: favorite_address.id, user_id: user.id } }
    let(:favorite_address) { create(:favorite_address, user_id: user.id) }

    before { delete :destroy, params: params }

    it { is_expected.to be_successful }

    context 'when something went wrong' do
      let(:params) { { id: 999 } }

      it { is_expected.to have_http_status(:not_found) }
    end
  end
end
